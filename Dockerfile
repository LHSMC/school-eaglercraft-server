FROM ghcr.io/yangchuansheng/eaglerx1.8server:2.2.7

RUN sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/server-1.8/run.sh && sed -i 's/256M/128M/g' /opt/eaglerX-1.8-server-image/bungee/run.sh
