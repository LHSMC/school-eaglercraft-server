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

# Forward Bungee/Paper console output directly into Render stdout without
# using tmux pipe-pane (which can race the tmux server/socket during startup).
RUN sed -i 's#exec ./run.sh"#exec ./run.sh 2>\&1 | tee /proc/1/fd/1"#' /opt/eaglerX-1.8-server-image/script/start_server.sh

# The base image's ENTRYPOINT was copied before our edits, so refresh the executable
# that Docker actually runs with the modified startup script.
RUN cp /opt/eaglerX-1.8-server-image/script/start_server.sh /usr/local/bin/eaglerx-start \
 && chmod +x /usr/local/bin/eaglerx-start

# Render exposes one public HTTP/WebSocket port. Configure the upstream
# Eaglercraft listener itself to use Render's $PORT at startup, so there is
# no extra TCP proxy in front of Bungee.
COPY render-entrypoint.sh /usr/local/bin/render-entrypoint.sh
RUN chmod +x /usr/local/bin/render-entrypoint.sh

EXPOSE 10000 5200

ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]
