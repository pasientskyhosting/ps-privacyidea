FROM ubuntu:trusty

RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ABF5BD827BD9BF62

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:privacyidea/privacyidea

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends --no-install-suggests \
        net-tools \
        tzdata \
        ca-certificates \
        supervisor \
        nginx \
        uwsgi \
        uwsgi-plugin-python \
        python-privacyidea \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/sites-enabled/
COPY conf/pi.cfg /etc/privacyidea/pi.cfg
COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx-site.conf /etc/nginx/sites-available/privacyidea
COPY privacyideaapp.py /etc/privacyidea/privacyideaapp.py
COPY privacyidea.xml /etc/uwsgi/apps-available/privacyidea.xml

COPY setup.sh /setup.sh
RUN /bin/sh /setup.sh

RUN pi-manage admin add admin -e admin@localhost -p test

EXPOSE 5000
VOLUME /etc/privacyidea
VOLUME /var/log/privacyidea
VOLUME /var/lib/privacyidea

CMD ["/usr/bin/supervisord","-n","-c", "/etc/supervisord.conf"]
