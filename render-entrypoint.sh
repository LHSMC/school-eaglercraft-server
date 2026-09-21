#!/bin/sh
set -eu

PROXY_PID=""
SERVER_PID=""

cleanup() {
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
        kill "$SERVER_PID" 2>/dev/null || true
    fi
    if [ -n "$PROXY_PID" ] && kill -0 "$PROXY_PID" 2>/dev/null; then
        kill "$PROXY_PID" 2>/dev/null || true
    fi
    wait "$SERVER_PID" 2>/dev/null || true
    wait "$PROXY_PID" 2>/dev/null || true
}
trap cleanup TERM INT EXIT

echo "[render] starting public proxy on 0.0.0.0:${PORT:-10000} -> 127.0.0.1:5200"
python3 /usr/local/bin/render-proxy.py &
PROXY_PID=$!

sleep 1

echo "[render] starting EaglerXServer on native listener 5200"
/usr/local/bin/eaglerx-start &
SERVER_PID=$!

wait "$SERVER_PID"
STATUS=$?

exit "$STATUS"
