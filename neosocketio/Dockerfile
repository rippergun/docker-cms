FROM node:7.0
MAINTAINER rippergun <rippergun@hotmail.com>

RUN apt-get -y update && apt-get install -y --allow-unauthenticated  vim supervisor

#supervisor
RUN mkdir -p /var/log/supervisor /run/php/

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#socketio
RUN cd /usr/local/lib && npm install -g socket.io request logger

EXPOSE 8888
CMD ["/usr/bin/supervisord"]
