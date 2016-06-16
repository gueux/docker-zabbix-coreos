FROM debian:jessie
MAINTAINER Nikolay Murga <work@murga.kiev.ua>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TERM xterm

# Install dependensies
RUN apt-get -y install \
        ucf \
        procps \
        iproute \
        supervisor && \
    apt-get -y install --no-install-recommends \
        curl \
        jq \
        libcurl3 \
        libldap-2.4-2 \
        netcat-openbsd \
        pciutils \
        sudo \
        fping \
        libiksemel3 \
        libiksemel-utils \
        wget \
        patch \
        build-essential \
        automake \
        apt-utils \
        pkg-config \
        libcurl4-openssl-dev \
        libiksemel-dev \
        libsnmp-dev

# Download source
RUN cd /tmp \
  && wget -O zabbix-3.0.3.tar.gz 'http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.0.3/zabbix-3.0.3.tar.gz' \
  && tar -zxvf zabbix-3.0.3.tar.gz

COPY files/zabbix-docker-3.0.3.patch /tmp/zabbix-docker-3.0.3.patch
RUN cd /tmp/zabbix-3.0.3 \
  && patch --verbose -p1 < /tmp/zabbix-docker-3.0.3.patch \
  && ./configure --prefix=/usr --sysconfdir=/etc/zabbix --enable-agent --enable-docker --with-libcurl \
  && make install

# Cleanup
RUN apt-get -f -y purge wget \
  patch \
  build-essential \
  automake \
  apt-utils \
  pkg-config \
  libcurl4-openssl-dev \
  libiksemel-dev \
  libsnmp-dev && \
  apt-get autoremove -f -y && \
  apt-get clean

# Create user
RUN mkdir /var/lib/zabbix && \
    useradd -r -s /bin/bash -d /var/lib/zabbix zabbix && \
    usermod -a -G adm zabbix

# Add configs user
COPY etc/zabbix/ /etc/zabbix/
COPY etc/supervisor/ /etc/supervisor/
COPY etc/sudoers.d/zabbix etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix && \
    chown -R zabbix:zabbix /var/lib/zabbix && \
    chown -R zabbix:zabbix /etc/zabbix

COPY run.sh /
RUN chmod +x /run.sh

EXPOSE 10050
ENTRYPOINT ["/run.sh"]
CMD ["/usr/bin/supervisord"]
