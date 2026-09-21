# LHSMC Eaglercraft 1.8.8 Server

Initial goal: prove that Eaglercraft 1.8.8 can connect reliably through Render at $0.

This image is based on EaglerXServer, using its Paper 1.8.8 runtime.

## Render settings

- Service type: Web Service
- Runtime: Docker
- Environment: `MINECRAFT_VERSION=1.8`
- Environment: `PORT=10000`
- Environment: `PUBLIC_GAME_URL=https://lhsmc-eaglercraft.onrender.com`
- Plan: Free

Render exposes only `0.0.0.0:$PORT`. A small TCP proxy forwards that public listener to the internal Eaglercraft WebSocket/HTTP listener on `127.0.0.1:5200`.

Do not add gameplay plugins until the basic connection test succeeds.
