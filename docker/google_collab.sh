#!/bin/bash -x

# Built with arch: amd64 flavor: lxde image: ubuntu:20.04
#
################################################################################
# base system
################################################################################

function MAINTAINER {
 echo SKIPPING: $*
}
function RUN {
 echo RUNing: $*
 $*
}

#FROM centminmod/docker-ubuntu-vnc-desktop
#FROM dickhub/ubuntu-xfce-vnc
#FROM ct2034/vnc-ros-kinetic-full
#FROM tiryoh/ros2-desktop-vnc
#FROM ros:noetic-desktop-full
#FROM tiryoh/ros-desktop-vnc:noetic
#MAINTAINER FROM dorowu/ubuntu-desktop-lxde-vnc:bionic
#LABEL maintainer="Tiryoh<tiryoh@gmail.com>"
#FROM aicampbell/vnc-ubuntu18-xfce
##EXPOSE 80

touch /tmp/is_google_collab

#USER root
#LABEL maintainer = "logicmoo@gmail.com"

export DEBIAN_FRONTEND=noninteractive

#
# from root@debian10:/opt/logicmoo_workspace
# we run..
#
# docker build -t logicmoo/logicmoo_starter_image:latest --no-cache --add-host=logicmoo.org:10.0.0.90 - < ./Dockerfile.distro
#

export LANG=C.UTF-8
export LANGUAGE=C.UTF-8
export LC_ALL=C.UTF-8
export LOGICMOO_USER=prologmud_server
export LOGICMOO_WS=/opt/logicmoo_workspace
export LOGICMOO_GAMES=$LOGICMOO_WS/prologmud_server


mkdir -p /usr/share/man/man1 \
 && apt update \
 && apt install -y apt-utils

apt-get install -y --allow-unauthenticated \
  nginx-common nginx nginx-core  libnginx-mod-http-geoip libnginx-mod-http-image-filter \
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream \
  supervisor apache2 nmap x11-apps vim eggdrop default-jdk default-jre \
  iproute2 libgd3 libgeoip1 libmnl0 libwebp6 libxslt1.1 \
  build-essential git autoconf texinfo libgnutls28-dev libxml2-dev libncurses5-dev libjansson-dev \
  libxpm-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev libjson*-dev libxf*-dev libwebkit2gtk-4.0-dev \
 python-is-python3 \
 python-dev-is-python3 \
 python3-gevent \
 python3-flask-api \
 python3-flask \
 python3-gevent-websocket \
 python3-novnc \
 python3-flask-sockets \
 iputils-ping \
 iputils-arping \
 nfs-kernel-server \
 nfs-common \
 rpcbind \
 telnet \
 traceroute \
 inotify-tools \
 ant \
 swig  \
 flex \
 libllvm8 \
 lsb-release \
 tzdata \
 gosu \
 zlib1g-dev \
 zlib1g \
 zip \
 yarn \
 xvfb \
 xtrans-dev \
 xterm \
 xorg-sgml-doctools \
 xfonts-base \
 xdotool \
 xauth \
 x11vnc \
 x11-utils \
 x11proto-xinerama-dev \
 x11proto-xext-dev \
 x11proto-dev \
 x11proto-core-dev \
 wget \
 vim \
 uuid-dev \
 unzip \
 unixodbc-dev \
 unixodbc \
 unattended-upgrades \
 tightvncserver \
 texlive-extra-utils \
 tdsodbc \
 supervisor \
 sudo \
 software-properties-common \
 screen \
 rsync

# apt-get install -y locales -qq && locale-gen en_AU \&& locale-gen en_AU.UTF-8 \ && dpkg-reconfigure locales \ && locale-gen C.UTF-8 \ && dpkg-reconfigure locales


mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
chmod a-w /etc/ssh/sshd_config.original
echo 'root:ubuntu' | chpasswd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
##EXPOSE 22 80
#CMD [“/usr/bin/supervisord”]
export USER=ubuntu
RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
    echo ubuntu:ubuntu | chpasswd && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

export USER=root
export HOME=/root




###########################
# EMACS LSP SUPPORT BEGIN #
###########################



#export TINI_VERSION=v0.19.0
#wget https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini -o /bin/tini
#chmod +x /bin/tinia
wget http://ftp.de.debian.org/debian/pool/main/t/tini/tini_0.18.0-1_amd64.deb -o /tmp/tini_0.18.0-1_amd64.deb
dpkg -i i/tmp/tini_0.18.0-1_amd64.deb
#RUN chmod +x run.sh
#RUN chmod 777 docker-entrypoint.sh

apt-get install -y software-properties-common curl gnupg2 && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && apt-get install -y \
  vault bash && \
  setcap cap_ipc_lock= /usr/bin/vault


apt-get install -y -q --no-install-recommends libapache2-mod-wsgi ; /bin/true 
apt-get install -y -q --no-install-recommends libapache2-mod-proxy-uwsgi  ; /bin/true 
apt-get install -y -q --no-install-recommends iputils-ping net-tools  ; /bin/true
apt-get install -y -q --no-install-recommends \
 php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl \
 php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring \
 php7.4-opcache php7.4-soap php7.4-zip php7.4-intl  ; /bin/true


# install our Butterfly websockets (telnet server over httpd)
pip install --upgrade pip ; python3 -m pip install --upgrade pip
python3 -m pip uninstall -y setuptools ; pip install setuptools
 python3 -m pip install --upgrade setuptools wheel
 python3 -m pip install tornado asyncio
 python3 -m pip install butterfly
 python3 -m pip install butterfly[themes] # If you want to use themes
 python3 -m pip install butterfly[systemd] # If you want to use systemd 
 cd /etc/systemd/system
 curl -O https://raw.githubusercontent.com/paradoxxxzero/butterfly/master/butterfly.service
 curl -O https://raw.githubusercontent.com/paradoxxxzero/butterfly/master/butterfly.socket
 systemctl enable butterfly.socket
 systemctl start butterfly.socket




# expose our used ports
#EXPOSE 22
#LSP (right?)
#EXPOSE 8123 5007 6001 5555 8543
#EXPOSE 4080
##EXPOSE 443 
#EXPOSE 4443
#EXPOSE 3020 4020
#EXPOSE 111 2049
##EXPOSE 139 445

# Phase three in case we forgot any above
 #python3-gevent-websocket \
 #python3-novnc \
 #python3-flask-sockets \



#LABEL maintainer = "logicmoo@gmail.com"
################################################################################
# merge
################################################################################
#FROM system
#LABEL maintainer="fcwu.tw@gmail.com"
##EXPOSE 80
#EXPOSE 4180
#EXPOSE 4022
#WORKDIR /root
export HOME=/root \
    SHELL=/bin/bash
# HEALTHCHECK --interval=60s --timeout=10s CMD curl --fail http://127.0.0.1:6079/api/health

#COPY rootfs /

echo "Set disable_coredump false" >> /etc/sudo.conf
# RUN useradd --create-home --home-dir /home/ubuntu --shell /bin/bash --user-group --groups adm,sudo ubuntu && \
echo ubuntu:ubuntu | chpasswd 
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

export USER=ubuntu

wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y /tmp/google-chrome-stable_current_amd64.deb
 

apt-get -y install --no-install-recommends apt-utils dialog 2>&1

apt install -y npm 
npm install -g typescript

#apt install -y mono-complete mono-4.0-gac mono-tools-devel
  

#ENTRYPOINT ["/startup_logicmoo.sh"]
#ENTRYPOINT ["/startup.sh"]
#ENTRYPOINT ["/bin/sh", "-ec", "while :; do echo '.'; sleep 600 ; done"]

cp -a packs_web/butterfly /tmp/butterfly/
cd /tmp/butterfly/ && pip3 install .

apt-get install -y --allow-unauthenticated \
  nginx-common nginx nginx-core  libnginx-mod-http-geoip libnginx-mod-http-image-filter \
  libnginx-mod-http-xslt-filter libnginx-mod-mail libnginx-mod-stream \
  supervisor apache2 nmap x11-apps vim eggdrop default-jdk default-jre \
  iproute2 libgd3 libgeoip1 libmnl0 libwebp6 libxslt1.1 \
 python3-gevent \
 python3-flask-api \
 iputils-ping \
 iputils-arping \
 nfs-kernel-server \
 nfs-common \
 rpcbind \
 telnet \
 traceroute \
 inotify-tools \
 ant \
 swig \
 flex \
 libllvm8 \
 lsb-release \
 tzdata \
 gosu \
 zlib1g-dev \
 zlib1g \
 zip \
 yarn \
 xvfb \
 xtrans-dev \
 xterm \
 xorg-sgml-doctools \
 xfonts-base \
 xdotool \
 xauth \
 x11vnc \
 x11-utils \
 x11proto-xinerama-dev \
 x11proto-xext-dev \
 x11proto-dev \
 x11proto-core-dev \
 wget \
 vim \
 uuid-dev \
 unzip \
 unixodbc-dev \
 unixodbc \
 unattended-upgrades \
 tightvncserver \
 texlive-extra-utils \
 tdsodbc \
 supervisor \
 sudo \
 software-properties-common \
 screen \
 rsync


apt-get install -y \
        build-essential cmake ninja-build pkg-config \
        ncurses-dev libreadline-dev libedit-dev \
        libgoogle-perftools-dev \
        libunwind-dev \
        libgmp-dev \
        libssl-dev \
        unixodbc-dev \
        zlib1g-dev libarchive-dev \
        libossp-uuid-dev \
        libxext-dev libice-dev libjpeg-dev libxinerama-dev libxft-dev \
        libxpm-dev libxt-dev \
        libdb-dev  libraptor2-dev \
        libpcre3-dev \
        libyaml-dev \
        default-jdk junit4 libserd-dev libserd-0-0

a2dismod mpm_event \
 && a2enmod macro access_compat alias auth_basic authn_core authn_file authz_core authz_host authz_user autoindex deflate dir env \
 filter headers http2 mime mpm_prefork negotiation  php7.4 proxy proxy_ajp proxy_balancer proxy_connect proxy_express \
 proxy_fcgi proxy_fdpass proxy_ftp proxy_hcheck proxy_html proxy_http proxy_http2 proxy_scgi proxy_uwsgi proxy_wstunnel reqtimeout \
 rewrite setenvif slotmem_shm socache_shmcb ssl status xml2enc ; /bin/true

# confirm our webconfig works (or it exits docker build) \
#service apache2 start && service apache2 status && service apache2 stop

# who/where
export LOGICMOO_GAMES=$LOGICMOO_WS/prologmud_server


apt-get update && apt-get install -y --allow-unauthenticated \
  libtinfo5 libtinfo6

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
 && apt update \
 && apt install -y gh

\cp $LOGICMOO_WS/packs_sys/logicmoo_nlu/requirements.txt /tmp/requirements.txt
\cp -a $LOGICMOO_WS/docker/rootfs/* /


