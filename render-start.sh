#!/bin/bash
set -u

export TMUX_TMPDIR="${TMUX_TMPDIR:-/tmp/eaglerx-tmux}"
export TMUX_SESSION="${TMUX_SESSION:-mcserver}"

ORIGINAL="/usr/local/bin/eaglerx-start-original"
MAIN_PID=""

cleanup() {
    if [ -n "${MAIN_PID}" ] && kill -0 "${MAIN_PID}" 2>/dev/null; then
        kill "${MAIN_PID}" 2>/dev/null || true
        wait "${MAIN_PID}" 2>/dev/null || true
    fi
    exit 0
}

trap cleanup TERM INT

echo "[render-debug] starting EaglerXServer with tmux output forwarding"

"${ORIGINAL}" &
MAIN_PID=$!

monitor_tmux() {
    while kill -0 "${MAIN_PID}" 2>/dev/null; do
        if tmux has-session -t "${TMUX_SESSION}" 2>/dev/null; then
            tmux list-panes -a -F '#{pane_id}' 2>/dev/null | while IFS= read -r pane; do
                [ -z "${pane}" ] && continue
                tmux pipe-pane -o -t "${pane}" 'cat > /proc/1/fd/1' 2>/dev/null || true
            done
        fi
        sleep 1
    done
}

monitor_tmux &
MONITOR_PID=$!

wait "${MAIN_PID}"
STATUS=$?

kill "${MONITOR_PID}" 2>/dev/null || true
wait "${MONITOR_PID}" 2>/dev/null || true

exit "${STATUS}"
