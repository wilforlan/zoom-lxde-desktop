################################################################################
# base system
################################################################################
FROM ubuntu:16.04 as system

ARG localbuild
RUN if [ "x$localbuild" != "x" ]; then sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list; fi

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common build-essential gnupg curl apache2-utils \
    && add-apt-repository ppa:fcwu-tw/apps \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor nginx sudo vim-tiny net-tools zenity xz-utils \
        dbus-x11 x11-utils alsa-utils \
        mesa-utils libgl1-mesa-dri \
        lxde x11vnc xvfb \
        gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        firefox chromium-browser \
        ttf-ubuntu-font-family ttf-wqy-zenhei \
        openjdk-8-jdk bc nano wget mtr dnsutils screen iputils-ping traceroute xz-utils tar \
        testssl.sh bsdmainutils nghttp2 \
        icedtea-netx icedtea-plugin \
        openssh-server pwgen\
        libxcb-keysyms1 libxcb-randr0 libxcb-image0 libxcb-xtest0 libxcb-xinerama0 ibus libxkbcommon-x11-0 \
    && add-apt-repository -r ppa:fcwu-tw/apps \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i 's|jdk.jar.disabledAlgorithms=MD2, MD5,|jdk.jar.disabledAlgorithms=MD2,|' /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security
# Additional packages require ~600MB
# libreoffice  pinta language-pack-zh-hant language-pack-gnome-zh-hant firefox-locale-zh-hant libreoffice-l10n-zh-tw

# tini for subreap                                   
ARG TINI_VERSION=v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD files /root

# ffmpeg
RUN mkdir -p /usr/local/ffmpeg \
    && curl -sSL https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz | tar xJvf - -C /usr/local/ffmpeg/ --strip 1

# python library
COPY image/usr/local/lib/web/backend/requirements.txt /tmp/
RUN apt-get update \
    && dpkg-query -W -f='${Package}\n' > /tmp/a.txt \
    && apt-get install -y python-pip python-dev build-essential \
  && pip install setuptools wheel && pip install -r /tmp/requirements.txt \
    && dpkg-query -W -f='${Package}\n' > /tmp/b.txt \
    && apt-get remove -y `diff --changed-group-format='%>' --unchanged-group-format='' /tmp/a.txt /tmp/b.txt | xargs` \
    && apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt/* /tmp/a.txt /tmp/b.txt

################################################################################
# builder
################################################################################
FROM ubuntu:16.04 as builder

ARG localbuild
RUN if [ "x$localbuild" != "x" ]; then sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list; fi

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl git ca-certificates

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get install -y nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

# clone submodules
RUN git clone https://github.com/novnc/noVNC.git web/static/novnc
RUN git clone https://github.com/novnc/websockify web/static/websockify

# build frontend
COPY web /src/web
RUN cd /src/web \
    && yarn \
    && npm run build


################################################################################
# merge
################################################################################
FROM system
LABEL maintainer="williams@fireflies.ai"

# download and install zoom client
ARG ZOOM_URL=https://zoom.us/client/latest/zoom_amd64.deb

RUN curl -sSL $ZOOM_URL -o /tmp/zoom_setup.deb
RUN dpkg -i /tmp/zoom_setup.deb

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.16.2

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl --silent -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.2/install.sh | bash

# install node and npm
RUN . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

COPY --from=builder /src/web/dist/ /usr/local/lib/web/frontend/
COPY image /

EXPOSE 80

WORKDIR /root

# copy file for our application install modules

COPY app /root/app
RUN cd /root/app \
    && npm install

ENV HOME=/home/ubuntu \
    SHELL=/bin/bash

HEALTHCHECK --interval=30s --timeout=5s CMD curl --fail http://127.0.0.1/api/health
ENTRYPOINT ["/startup.sh"]
