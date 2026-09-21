FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

RUN sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/server-1.8/run.sh && sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/bungee/run.sh

# Keep the admin HTTP service private. Render should expose the Eaglercraft
# game/WebSocket listener on 5200, not the admin service on 5201.
RUN sed -i "s/ThreadingHTTPServer(('0.0.0.0', PORT)/ThreadingHTTPServer(('127.0.0.1', PORT)/" /opt/eaglerX-1.8-server-image/script/http_server.py

# The upstream Bungee query listener on 127.0.0.1:25577 is not needed for
# Eaglercraft and can be mistaken for Render's public HTTP port while the
# Eagler listener is still starting. Bind that optional listener to an
# ephemeral local port instead.
RUN sed -i 's/query_port: 25577/query_port: 0/' /opt/eaglerX-1.8-server-image/bungee/config.yml \
 && sed -i 's/host: 127.0.0.1:25577/host: 127.0.0.1:0/' /opt/eaglerX-1.8-server-image/bungee/config.yml

EXPOSE 5200

RUN cp /usr/local/bin/eaglerx-start /usr/local/bin/eaglerx-start-original

COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

ENTRYPOINT ["/usr/local/bin/render-start.sh"]
