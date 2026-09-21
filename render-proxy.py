#!/usr/bin/env python3
import os
import socket
import threading

LISTEN_HOST = "0.0.0.0"
LISTEN_PORT = int(os.environ.get("PORT", "10000"))
TARGET_HOST = "127.0.0.1"
TARGET_PORT = 5200

def pipe(src, dst):
    try:
        while True:
            data = src.recv(65536)
            if not data:
                break
            dst.sendall(data)
    except (ConnectionError, OSError):
        pass
    finally:
        try:
            dst.shutdown(socket.SHUT_WR)
        except OSError:
            pass

def handle(client):
    try:
        client.settimeout(5)
        first = client.recv(8192)
        if not first:
            return

        # Render's port/health probes send HTTP HEAD requests. Do not pass
        # those probes into the Minecraft/Eagler protocol handler.
        if first.startswith(b"HEAD "):
            client.sendall(
                b"HTTP/1.1 200 OK\r\n"
                b"Content-Length: 0\r\n"
                b"Connection: close\r\n\r\n"
            )
            return

        upstream = socket.create_connection((TARGET_HOST, TARGET_PORT), timeout=15)
        upstream.settimeout(None)
        upstream.sendall(first)

        t1 = threading.Thread(target=pipe, args=(client, upstream), daemon=True)
        t2 = threading.Thread(target=pipe, args=(upstream, client), daemon=True)
        t1.start()
        t2.start()
        t1.join()
        t2.join()
    except (ConnectionError, OSError, TimeoutError):
        pass
    finally:
        try:
            client.close()
        except OSError:
            pass

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind((LISTEN_HOST, LISTEN_PORT))
server.listen(128)

print(f"[render-proxy] listening on {LISTEN_HOST}:{LISTEN_PORT}", flush=True)
print(f"[render-proxy] forwarding game traffic to {TARGET_HOST}:{TARGET_PORT}", flush=True)

while True:
    client, addr = server.accept()
    threading.Thread(target=handle, args=(client,), daemon=True).start()
