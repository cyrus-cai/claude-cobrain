#!/usr/bin/env bash
#
# cobrain status - standalone status check (no LLM needed)
#
# Usage:
#   ./status.sh                     # run directly
#   /claude-cobrain:status          # via Claude Code skill
#

set -euo pipefail

# ── Colors ──────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD='\033[1m'
  DIM='\033[2m'
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  BOLD='' DIM='' GREEN='' RED='' YELLOW='' CYAN='' NC=''
fi

# ── Resolve paths ───────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_JSON="$PLUGIN_ROOT/.claude-plugin/plugin.json"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
PID_FILE="$OUTPUT_DIR/cobrain.pid"
DEPLOYED_SCRIPT="$OUTPUT_DIR/cobrain.py"
PLUGIN_SCRIPT="$PLUGIN_ROOT/scripts/cobrain.py"
RUNTIME_OUT="$OUTPUT_DIR/runtime.stdout.log"
RUNTIME_ERR="$OUTPUT_DIR/runtime.stderr.log"
TODAY=$(date +%Y%m%d)

# ── Helpers ─────────────────────────────────────────────
warnings=()

warn() { warnings+=("$1"); }

# ── 1. Version ──────────────────────────────────────────
if [[ -f "$PLUGIN_JSON" ]]; then
  VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON')).get('version','unknown'))" 2>/dev/null || echo "unknown")
else
  VERSION="unknown"
fi

# ── 2. Process ──────────────────────────────────────────
PID=""
if [[ -f "$PID_FILE" ]]; then
  CANDIDATE_PID=$(cat "$PID_FILE" 2>/dev/null || true)
  if [[ -n "$CANDIDATE_PID" ]] && kill -0 "$CANDIDATE_PID" 2>/dev/null; then
    PID="$CANDIDATE_PID"
  fi
fi
if [[ -z "$PID" ]]; then
  PID=$(pgrep -f "$DEPLOYED_SCRIPT" 2>/dev/null | head -n1 || true)
fi
if [[ -n "$PID" ]]; then
  PROCESS="${GREEN}running${NC} (PID $PID)"
else
  PROCESS="${RED}not running${NC}"
fi

# ── 3. Python ───────────────────────────────────────────
PYTHON=$(command -v python3.11 2>/dev/null || command -v python3 2>/dev/null || echo "")
if [[ -n "$PYTHON" ]]; then
  PYTHON_STATUS="$PYTHON"
else
  PYTHON_STATUS="${RED}not found${NC}"
  warn "Python 3.11+ not found"
fi

# ── 4. Script ───────────────────────────────────────────
if [[ -f "$DEPLOYED_SCRIPT" ]]; then
  SCRIPT_STATUS="$DEPLOYED_SCRIPT"
elif [[ -f "$PLUGIN_SCRIPT" ]]; then
  SCRIPT_STATUS="$PLUGIN_SCRIPT (not deployed)"
else
  SCRIPT_STATUS="${RED}not found${NC}"
fi

# ── 5. Screen Recording ────────────────────────────────
TMPFILE="/tmp/cobrain_perm_test_$$.png"
if /usr/sbin/screencapture -x "$TMPFILE" 2>/dev/null && [[ -f "$TMPFILE" ]]; then
  SIZE=$(stat -f%z "$TMPFILE" 2>/dev/null || echo "0")
  rm -f "$TMPFILE"
  if [[ "$SIZE" -gt 100 ]]; then
    SCREEN="${GREEN}granted${NC}"
  else
    SCREEN="${RED}DENIED${NC}"
    warn "Screen Recording not granted. Run: /claude-cobrain:cobrain restart"
  fi
else
  rm -f "$TMPFILE"
  SCREEN="${RED}DENIED${NC}"
  warn "Screen Recording not granted. Run: /claude-cobrain:cobrain restart"
fi

# ── 6. Ollama model ────────────────────────────────────
OLLAMA_MODEL="${OLLAMA_MODEL:-qwen3-vl:2b}"
# Ensure homebrew paths are available in non-interactive shells (e.g. skill execution)
[[ -d /opt/homebrew/bin ]] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]] && export PATH="/opt/homebrew/bin:$PATH"
[[ -d /usr/local/bin ]] && [[ ":$PATH:" != *":/usr/local/bin:"* ]] && export PATH="/usr/local/bin:$PATH"
if ! command -v ollama &>/dev/null; then
  OLLAMA="${RED}not installed${NC}"
  warn "Ollama not found. Install from https://ollama.com"
else
  # Capture output first to avoid SIGPIPE (exit 141) with pipefail + grep -q
  OLLAMA_LIST=$(ollama list 2>/dev/null || true)
  if [[ -z "$OLLAMA_LIST" ]]; then
    OLLAMA="${YELLOW}server not running${NC}"
    warn "Ollama app not running. Start Ollama.app first"
  elif echo "$OLLAMA_LIST" | grep -q "${OLLAMA_MODEL%%:*}"; then
    OLLAMA="${GREEN}${OLLAMA_MODEL} available${NC}"
  else
    OLLAMA="${YELLOW}server running, model missing${NC}"
    warn "Model not found. Run: ollama pull $OLLAMA_MODEL"
  fi
fi

# ── 7. Today's file ────────────────────────────────────
TODAY_FILE="$OUTPUT_DIR/${TODAY}-raw.md"
if [[ -f "$TODAY_FILE" ]]; then
  FSIZE=$(stat -f%z "$TODAY_FILE" 2>/dev/null || echo "?")
  TODAY_STATUS="${TODAY}-raw.md (${FSIZE} bytes)"
else
  TODAY_STATUS="${DIM}not yet created${NC}"
fi

# ── 8. Last log activity ───────────────────────────────
LOG_FILE="$OUTPUT_DIR/daemon.log"
if [[ -f "$LOG_FILE" ]]; then
  LAST_LOG=$(tail -1 "$LOG_FILE" 2>/dev/null || echo "empty")
else
  LAST_LOG="${DIM}no daemon.log${NC}"
fi

# ── 9. Runtime stderr/stdout ────────────────────────────
if [[ -f "$RUNTIME_OUT" ]]; then
  LAST_RUNTIME_OUT=$(tail -1 "$RUNTIME_OUT" 2>/dev/null || echo "empty")
else
  LAST_RUNTIME_OUT="${DIM}no runtime.stdout.log${NC}"
fi
if [[ -f "$RUNTIME_ERR" ]]; then
  LAST_RUNTIME_ERR=$(tail -1 "$RUNTIME_ERR" 2>/dev/null || echo "empty")
else
  LAST_RUNTIME_ERR="${DIM}no runtime.stderr.log${NC}"
fi

# ── Output ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}cobrain v${VERSION}${NC}"
echo -e "${DIM}─────────────────────────────${NC}"
echo -e "  Process:          $PROCESS"
echo -e "  Python:           $PYTHON_STATUS"
echo -e "  Script:           $SCRIPT_STATUS"
echo -e "  Output dir:       $OUTPUT_DIR"
echo -e "${DIM}─────────────────────────────${NC}"
echo -e "  Screen Recording: $SCREEN"
echo -e "  Ollama:           $OLLAMA"
echo -e "${DIM}─────────────────────────────${NC}"
echo -e "  Today's log:      $TODAY_STATUS"
echo -e "  Last activity:    $LAST_LOG"
echo -e "  Runtime stdout:   $LAST_RUNTIME_OUT"
echo -e "  Runtime stderr:   $LAST_RUNTIME_ERR"
echo ""

# ── Warnings ────────────────────────────────────────────
for w in "${warnings[@]+"${warnings[@]}"}"; do
  echo -e "  ${YELLOW}⚠ ${w}${NC}"
done
if [[ ${#warnings[@]} -gt 0 ]]; then
  echo ""
fi
