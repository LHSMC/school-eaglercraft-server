#!/bin/sh
set -eu

PORT_VALUE="${PORT:-10000}"
APP="/opt/eaglerX-1.8-server-image"

echo "[render] configuring Eaglercraft public listener for 0.0.0.0:${PORT_VALUE}"

# The upstream EaglerXServer uses 5200 as its normal public listener.
# Render only exposes the service's $PORT publicly, so change both the
# listener address and the startup readiness check to Render's port.
sed -i "s#0.0.0.0:5200#0.0.0.0:${PORT_VALUE}#" "${APP}/bungee/plugins/EaglercraftXBungee/listeners.yml"
sed -i "s#127.0.0.1 5200#127.0.0.1 ${PORT_VALUE}#" "/usr/local/bin/eaglerx-start"

echo "[render] starting EaglerXServer; public listener will be 0.0.0.0:${PORT_VALUE}"
exec /usr/local/bin/eaglerx-start
