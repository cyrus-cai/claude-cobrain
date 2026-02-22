#!/usr/bin/env python3
"""
co-brain daemon
- every 30s capture the active window
- allow backend: ollama | fastvlm
- append to <OUTPUT_DIR>/YYYYMMDD-raw.md

Usage:
  python cobrain.py                         # default ollama/qwen3-vl:2b
  MODEL_BACKEND=fastvlm FASTVLM_PATH=~/ml-fastvlm FASTVLM_MODEL=~/ml-fastvlm/checkpoints/fastvlm-0.5b python cobrain.py
"""

import base64
import ctypes
import ctypes.util
import hashlib
import io
import logging
import logging.handlers
import os
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path

from PIL import Image

# ── Settings (can be overridden by environment variables) ─────────────────────────
INTERVAL      = int(os.environ.get("INTERVAL", 30))
MAX_WIDTH     = int(os.environ.get("MAX_WIDTH", 800))
JPEG_QUALITY  = int(os.environ.get("JPEG_QUALITY", 75))
OUTPUT_DIR    = Path(os.environ.get("OUTPUT_DIR", Path.home() / ".claude" / "cobrain"))
PROMPT        = os.environ.get("PROMPT", "Summarize the key content of the screenshot clearly in original language, with the purpose of providing long-term memory for the AI, without including any irrelevant elements.")
IDLE_TIMEOUT  = int(os.environ.get("IDLE_TIMEOUT", 180))   # seconds of no input → skip capture

# backend: "ollama" | "fastvlm"
MODEL_BACKEND = os.environ.get("MODEL_BACKEND", "ollama")

# ollama config
OLLAMA_MODEL  = os.environ.get("OLLAMA_MODEL", "qwen3-vl:2b")

# fastvlm config
FASTVLM_PATH  = Path(os.environ.get("FASTVLM_PATH", Path.home() / "ml-fastvlm"))
FASTVLM_MODEL = os.environ.get("FASTVLM_MODEL", "")

SKIP_APPS = {"Dock", "SystemUIServer", "Control Centre", "NotificationCenter", "loginwindow"}
# ──────────────────────────────────────────────────


# ── Idle detection (macOS) ────────────────────────────────────

_cg = ctypes.CDLL(ctypes.util.find_library("CoreGraphics"))
_cg.CGEventSourceSecondsSinceLastEventType.restype = ctypes.c_double
_cg.CGEventSourceSecondsSinceLastEventType.argtypes = [ctypes.c_int32, ctypes.c_uint32]

def get_idle_seconds() -> float:
    """Return seconds since last keyboard/mouse event."""
    # kCGEventSourceStateCombinedSessionState = 0, kCGAnyInputEventType = ~0
    return _cg.CGEventSourceSecondsSinceLastEventType(0, 0xFFFFFFFF)


# ── Image dedup ──────────────────────────────────────────────

_last_img_hash = None

def is_duplicate_image(img_bytes: bytes) -> bool:
    """Return True if screenshot is identical to the previous one."""
    global _last_img_hash
    h = hashlib.md5(img_bytes).digest()
    if h == _last_img_hash:
        return True
    _last_img_hash = h
    return False


def _setup_logging():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    log_path = OUTPUT_DIR / "daemon.log"
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    fmt = logging.Formatter("%(asctime)s [%(levelname)s] %(message)s", datefmt="%H:%M:%S")

    file_handler = logging.handlers.RotatingFileHandler(
        log_path, maxBytes=10 * 1024 * 1024, backupCount=3, encoding="utf-8"
    )
    file_handler.setFormatter(fmt)
    logger.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(fmt)
    logger.addHandler(console_handler)


_setup_logging()
log = logging.getLogger(__name__)


# ── Screenshot ────────────────────────────────────────── 

def get_frontmost_window_bounds():
    script = """
tell application "System Events"
    set frontProc to first process whose frontmost is true
    set appName to name of frontProc
    set wins to windows of frontProc
    if (count of wins) > 0 then
        set win to item 1 of wins
        set pos to position of win
        set sz to size of win
        return (item 1 of pos) & "," & (item 2 of pos) & "," & (item 1 of sz) & "," & (item 2 of sz) & "," & appName
    end if
end tell"""
    result = subprocess.run(["osascript", "-e", script], capture_output=True, text=True)
    parts = [p.strip() for p in result.stdout.strip().split(",")]
    parts = [p for p in parts if p]
    if len(parts) >= 5:
        return int(parts[0]), int(parts[1]), int(parts[2]), int(parts[3]), parts[4]
    return None


def capture_active_window():
    """返回 (img_b64, img_tmp_path, app)"""
    bounds = get_frontmost_window_bounds()
    if not bounds:
        return None, None, None
    x, y, w, h, app = bounds
    if app in SKIP_APPS:
        return None, None, app
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
        png_tmp = f.name
    result = subprocess.run(["screencapture", "-x", "-R", f"{x},{y},{w},{h}", png_tmp], timeout=3)
    if result.returncode != 0 or os.path.getsize(png_tmp) == 0:
        os.unlink(png_tmp)
        return None, None, app
    img = Image.open(png_tmp).convert("RGB")
    os.unlink(png_tmp)
    if img.width > MAX_WIDTH:
        ratio = MAX_WIDTH / img.width
        img = img.resize((MAX_WIDTH, int(img.height * ratio)), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=JPEG_QUALITY)
    img_b64 = base64.b64encode(buf.getvalue()).decode()
    # fastvlm 需要实际文件路径
    with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as f:
        jpg_tmp = f.name
    img.save(jpg_tmp, format="JPEG", quality=JPEG_QUALITY)
    return img_b64, jpg_tmp, app


# ── Backend: ollama ────────────────────────────────

def describe_ollama(img_b64: str) -> str:
    import ollama
    response = ollama.chat(
        model=OLLAMA_MODEL,
        messages=[{"role": "user", "content": PROMPT, "images": [img_b64]}],
        options={"think": False},
    )
    return response["message"]["content"].strip()


# ── Backend: fastvlm ──────────────────────────────

_fastvlm_predict = None

def _load_fastvlm():
    global _fastvlm_predict
    if _fastvlm_predict is not None:
        return
    sys.path.insert(0, str(FASTVLM_PATH))
    from predict import predict
    _fastvlm_predict = predict
    log.info(f"FastVLM loaded from {FASTVLM_PATH}")

def describe_fastvlm(img_path: str) -> str:
    import argparse, io as _io
    _load_fastvlm()
    args = argparse.Namespace(
        model_path=FASTVLM_MODEL,
        model_base=None,
        image_file=img_path,
        prompt=PROMPT,
        conv_mode="qwen_2",
        temperature=0.2,
        top_p=None,
        num_beams=1,
    )
    captured = _io.StringIO()
    old_stdout = sys.stdout
    sys.stdout = captured
    try:
        _fastvlm_predict(args)
    finally:
        sys.stdout = old_stdout
    return captured.getvalue().strip()


# ── describe  ─────────────────────────────────

def describe(img_b64: str, img_path: str) -> str:
    if MODEL_BACKEND == "fastvlm":
        return describe_fastvlm(img_path)
    return describe_ollama(img_b64)


# ── output ──────────────────────────────────────────

def output_file(dt: datetime) -> Path:
    return OUTPUT_DIR / f"{dt.strftime('%Y%m%d')}-raw.md"

def ensure_header(path: Path, dt: datetime):
    if not path.exists():
        label = f"ollama/{OLLAMA_MODEL}" if MODEL_BACKEND == "ollama" else f"fastvlm/{FASTVLM_MODEL}"
        path.write_text(
            f"# {dt.strftime('%Y-%m-%d')} · Live Memory\n\n"
            f"_Source: {label}_\n\n"
        )

def write_entry(app: str, summary: str):
    now = datetime.now()
    path = output_file(now)
    ensure_header(path, now)
    ts = now.strftime("%H:%M:%S")
    entry = f"\n### {ts} · {app}\n{summary}\n"
    with open(path, "a", encoding="utf-8") as f:
        f.write(entry)


# ── main loop ────────────────────────────────────────

def run():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    log.info(f"co-brain started | backend={MODEL_BACKEND} | interval={INTERVAL}s | output={OUTPUT_DIR}")

    _idle_logged = False

    while True:
        t0 = time.time()
        img_path = None
        try:
            # ── idle detection ──
            idle = get_idle_seconds()
            if idle >= IDLE_TIMEOUT:
                if not _idle_logged:
                    log.info(f"idle {idle:.0f}s ≥ {IDLE_TIMEOUT}s, pausing")
                    _idle_logged = True
                sleep_time = max(0, INTERVAL - (time.time() - t0))
                time.sleep(sleep_time)
                continue
            _idle_logged = False

            img_b64, img_path, app = capture_active_window()
            if img_b64:
                # ── duplicate detection ──
                if is_duplicate_image(base64.b64decode(img_b64)):
                    log.info(f"skip: {app} (duplicate)")
                else:
                    summary = describe(img_b64, img_path)
                    write_entry(app, summary)
                    elapsed = time.time() - t0
                    log.info(f"{app} | {elapsed:.1f}s | {summary}")
            elif app:
                log.info(f"skip: {app}")
        except KeyboardInterrupt:
            log.info("stopped.")
            break
        except Exception as e:
            log.error(f"error: {e}", exc_info=True)
        finally:
            if img_path and os.path.exists(img_path):
                os.unlink(img_path)

        sleep_time = max(0, INTERVAL - (time.time() - t0))
        time.sleep(sleep_time)


if __name__ == "__main__":
    run()
