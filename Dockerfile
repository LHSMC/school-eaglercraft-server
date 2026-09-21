FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

RUN sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/server-1.8/run.sh && sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/bungee/run.sh

RUN cp /usr/local/bin/eaglerx-start /usr/local/bin/eaglerx-start-original

COPY render-start.sh /usr/local/bin/render-start.sh
RUN chmod +x /usr/local/bin/render-start.sh

ENTRYPOINT ["/usr/local/bin/render-start.sh"]
