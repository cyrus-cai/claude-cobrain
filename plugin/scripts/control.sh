#!/usr/bin/env bash
#
# cobrain process control (direct python3 mode)
#
# Usage:
#   ./control.sh start|stop|restart|status|logs
#

set -euo pipefail

ACTION="${1:-status}"

OUTPUT_DIR="${OUTPUT_DIR:-$HOME/.claude/cobrain}"
PID_FILE="$OUTPUT_DIR/cobrain.pid"
SCRIPT_PATH="$OUTPUT_DIR/cobrain.py"
RUNTIME_STDOUT="$OUTPUT_DIR/runtime.stdout.log"
RUNTIME_STDERR="$OUTPUT_DIR/runtime.stderr.log"
DAEMON_LOG="$OUTPUT_DIR/daemon.log"
LEGACY_PLIST="$HOME/Library/LaunchAgents/com.cobrain.plist"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_SCRIPT="$SCRIPT_DIR/cobrain.py"

detect_python() {
  command -v python3 2>/dev/null || true
}

ensure_runtime_dir() {
  mkdir -p "$OUTPUT_DIR"
}

ensure_script() {
  ensure_runtime_dir
  if [[ -f "$PLUGIN_SCRIPT" ]]; then
    if [[ ! -f "$SCRIPT_PATH" ]] || ! cmp -s "$PLUGIN_SCRIPT" "$SCRIPT_PATH"; then
      cp "$PLUGIN_SCRIPT" "$SCRIPT_PATH"
    fi
  elif [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Missing daemon script: $SCRIPT_PATH"
    exit 1
  fi
}

running_pids() {
  pgrep -f "$SCRIPT_PATH" 2>/dev/null || true
}

is_running() {
  [[ -n "$(running_pids)" ]]
}

print_log_paths() {
  echo "Logs:"
  echo "  $DAEMON_LOG"
  echo "  $RUNTIME_STDOUT"
  echo "  $RUNTIME_STDERR"
}

show_recent_logs() {
  echo "Recent logs:"
  tail -50 "$DAEMON_LOG" 2>/dev/null || echo "  missing: $DAEMON_LOG"
  tail -50 "$RUNTIME_STDERR" 2>/dev/null || echo "  missing: $RUNTIME_STDERR"
}

disable_legacy_launchagent() {
  launchctl unload "$LEGACY_PLIST" 2>/dev/null || true
}

start_daemon() {
  ensure_script
  disable_legacy_launchagent

  if is_running; then
    PIDS="$(running_pids | tr '\n' ' ')"
    echo "Already running (PID: $PIDS)"
    print_log_paths
    return 0
  fi

  PYTHON_BIN="$(detect_python)"
  [[ -n "$PYTHON_BIN" ]] || { echo "python3 not found"; exit 1; }

  nohup "$PYTHON_BIN" "$SCRIPT_PATH" >>"$RUNTIME_STDOUT" 2>>"$RUNTIME_STDERR" &
  PID="$!"
  echo "$PID" > "$PID_FILE"

  sleep 2
  if kill -0 "$PID" 2>/dev/null; then
    PIDS="$(running_pids | tr '\n' ' ')"
    echo "Started cobrain (PID: $PIDS)"
    print_log_paths
  else
    echo "Failed to start cobrain."
    show_recent_logs
    exit 1
  fi
}

stop_daemon() {
  disable_legacy_launchagent
  ensure_runtime_dir

  PIDS="$(running_pids)"
  if [[ -z "$PIDS" ]]; then
    rm -f "$PID_FILE"
    echo "cobrain is not running"
    return 0
  fi

  while IFS= read -r pid; do
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  done <<< "$PIDS"

  sleep 1
  REMAINING="$(running_pids)"
  if [[ -n "$REMAINING" ]]; then
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && kill -9 "$pid" 2>/dev/null || true
    done <<< "$REMAINING"
  fi

  sleep 1
  if is_running; then
    echo "Stop failed: cobrain.py is still running"
    running_pids
    exit 1
  fi

  rm -f "$PID_FILE"
  echo "Stopped"
}

show_status() {
  ensure_runtime_dir
  echo "Output dir: $OUTPUT_DIR"
  if is_running; then
    PIDS="$(running_pids | tr '\n' ' ')"
    echo "Process: running (PID: $PIDS)"
  else
    echo "Process: not running"
  fi
  print_log_paths
  tail -1 "$DAEMON_LOG" 2>/dev/null || true
}

show_logs() {
  ensure_runtime_dir
  echo "Process:"
  running_pids || true
  tail -50 "$DAEMON_LOG" 2>/dev/null || echo "missing: $DAEMON_LOG"
  tail -50 "$RUNTIME_STDOUT" 2>/dev/null || echo "missing: $RUNTIME_STDOUT"
  tail -50 "$RUNTIME_STDERR" 2>/dev/null || echo "missing: $RUNTIME_STDERR"
}

case "$ACTION" in
  start) start_daemon ;;
  stop) stop_daemon ;;
  restart) stop_daemon; start_daemon ;;
  status) show_status ;;
  logs) show_logs ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Usage: $0 start|stop|restart|status|logs"
    exit 1
    ;;
esac
