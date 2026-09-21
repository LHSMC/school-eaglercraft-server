FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

RUN sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/server-1.8/run.sh && sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/bungee/run.sh

# Keep the upstream admin HTTP service private.
RUN sed -i "s/ThreadingHTTPServer(('0.0.0.0', PORT)/ThreadingHTTPServer(('127.0.0.1', PORT)/" /opt/eaglerX-1.8-server-image/script/http_server.py

# Keep Bungee's optional query listener private and out of Render's port scan.
RUN sed -i 's/query_port: 25577/query_port: 0/' /opt/eaglerX-1.8-server-image/bungee/config.yml \
 && sed -i 's/host: 127.0.0.1:25577/host: 127.0.0.1:0/' /opt/eaglerX-1.8-server-image/bungee/config.yml

# The Eagler listener itself stays internal. Render-facing traffic enters
# through render-proxy.py on $PORT and is forwarded to 127.0.0.1:5200.
RUN sed -i 's/address: 0.0.0.0:5200/address: 127.0.0.1:5200/' /opt/eaglerX-1.8-server-image/bungee/plugins/EaglercraftXBungee/listeners.yml

EXPOSE 10000

RUN cp /usr/local/bin/eaglerx-start /usr/local/bin/eaglerx-start-original

COPY render-proxy.py /usr/local/bin/render-proxy.py
COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

ENTRYPOINT ["/usr/local/bin/render-start.sh"]
