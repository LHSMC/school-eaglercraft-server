FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

# Render Free has limited RAM. Give Paper enough heap to generate the 1.8.8
# world, while keeping the proxy/Bungee side small enough to coexist.
RUN sed -i 's/-Xmx256M -Xms256M/-Xmx192M -Xms192M/' /opt/eaglerX-1.8-server-image/server-1.8/run.sh \
 && sed -i 's/-Xmx256M -Xms256M/-Xmx96M -Xms96M/' /opt/eaglerX-1.8-server-image/bungee/run.sh

# Keep the upstream admin HTTP service private.
RUN sed -i "s/ThreadingHTTPServer(('0.0.0.0', PORT)/ThreadingHTTPServer(('127.0.0.1', PORT)/" /opt/eaglerX-1.8-server-image/script/http_server.py

# Keep Bungee's optional query listener private and out of Render's port scan.
RUN sed -i 's/query_port: 25577/query_port: 0/' /opt/eaglerX-1.8-server-image/bungee/config.yml \
 && sed -i 's/host: 127.0.0.1:25577/host: 127.0.0.1:0/' /opt/eaglerX-1.8-server-image/bungee/config.yml

# Render can forward HTTP/WebSocket traffic directly to the Eagler listener.
# Put the Eagler game listener on Render's public PORT so there is no extra
# TCP proxy layer between Render's WebSocket edge and EaglercraftXBungee.
RUN sed -i 's/address: 0.0.0.0:5200/address: 0.0.0.0:10000/' /opt/eaglerX-1.8-server-image/bungee/plugins/EaglercraftXBungee/listeners.yml

EXPOSE 10000

ENTRYPOINT ["/usr/local/bin/eaglerx-start"]
