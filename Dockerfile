FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

RUN sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/server-1.8/run.sh && sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/bungee/run.sh

# Render Web Services can expose only one public HTTP port. The upstream
# admin server is meant to stay private on 5201 so Render selects the
# Eaglercraft game/WebSocket port 5200 instead.
RUN sed -i "s/ThreadingHTTPServer(('0.0.0.0', PORT)/ThreadingHTTPServer(('127.0.0.1', PORT)/" /opt/eaglerX-1.8-server-image/script/http_server.py

EXPOSE 5200

RUN cp /usr/local/bin/eaglerx-start /usr/local/bin/eaglerx-start-original

COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

ENTRYPOINT ["/usr/local/bin/render-start.sh"]
