FROM ubuntu:bionic

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="ISLE IIIF Image Service" \
      org.label-schema.description="Cantaloupe IIIF to serve all your image needs." \
      org.label-schema.url="https://islandora-collaboration-group.github.io" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Islandora-Collaboration-Group/isle-iiif" \
      org.label-schema.vendor="Islandora Collaboration Group (ICG) - islandora-consortium-group@googlegroups.com" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      traefik.enable="true" \
      traefik.port="8182" \
      traefik.backend="isle-imageservice"

## S6-Overlay @see: https://github.com/just-containers/s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
    rm /tmp/s6-overlay-amd64.tar.gz

###
# Dependencies 
RUN GEN_DEP_PACKS="ca-certificates \
    dnsutils \
    wget \
    curl\
    git \
    unzip" && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends $GEN_DEP_PACKS && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
# FFMPEG and GhostScript 
RUN FFMPEG_GS_PACKS="ffmpeg \
    ffmpeg2theora \
    libavcodec-extra \
    ghostscript \
    xpdf \
    poppler-utils" && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends $FFMPEG_GS_PACKS && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
# ImageMagick and OpenJPG
RUN BUILD_DEPS="build-essential \
    cmake \
    pkg-config \
    libtool" && \
    IMAGEMAGICK_LIBS="libbz2-dev \
    libdjvulibre-dev \
    libexif-dev \
    libgif-dev \
    libjpeg8 \
    libjpeg-dev \
    liblqr-dev \
    libopenexr-dev \
    libopenjp2-7-dev \
    libpng-dev \
    libraw-dev \
    librsvg2-dev \
    libtiff-dev \
    libwmf-dev \
    libwebp-dev \
    libwmf-dev \
    zlib1g-dev" && \
    ## These are unused and actually install by libavcodec-extra, I believe.
    IMAGEMAGICK_LIBS_EXTENDED="libfontconfig \
    libfreetype6-dev" && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    apt-get install -y --no-install-recommends -o APT::Get::Install-Automatic=true $BUILD_DEPS && \
    apt-mark auto $BUILD_DEPS && \
    apt-get install -y --no-install-recommends $IMAGEMAGICK_LIBS && \
    cd /tmp && \
    git clone https://github.com/uclouvain/openjpeg && \
    cd openjpeg && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    ldconfig && \
    cd /tmp && \
    wget https://www.imagemagick.org/download/ImageMagick.tar.gz && \
    tar xf ImageMagick.tar.gz && \
    cd ImageMagick-* && \
    ./configure --enable-hdri --with-quantum-depth=16 --without-x --without-magick-plus-plus --without-perl --with-rsvg && \
    make && \
    make install && \
    ldconfig && \
    ## Cleanup phase.
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

###
# Cantaloupe 3.4.3 because I failed 4.x, and also failed to get this running as of 2018-08-05. Giving up for now.
# Ultimate thanks to Diego Pino Navarro's work on the Islandora Vagrant, for which the properties and delegates are copied from.
RUN cd /tmp && \
    wget https://github.com/medusa-project/cantaloupe/releases/download/v3.4.3/Cantaloupe-3.4.3.zip && \
    unzip Cantaloupe-*.zip && \
    rm Cantaloupe-3.4.3/*.sample && \
    mkdir -p /usr/local/cantaloupe /usr/local/cantaloupe/temp /var/log/cantaloupe && \
    cp Cantaloupe-3.4.3/* /usr/local/cantaloupe && \
    ## Cleanup Phase.
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## JAVA PHASE
## Oracle Java 8, default.
RUN echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 boolean true' | debconf-set-selections && \
    LAZY_PACK="software-properties-common" && \
    apt-get update && \
    apt-get install -y --no-install-recommends -o APT::Get::Install-Automatic=true $LAZY_PACK && \
    add-apt-repository -y ppa:webupd8team/java && \
    JAVA_PACKAGES="oracle-java8-installer \
    oracle-java8-set-default" && \
    apt-get update && \
    apt-get install --no-install-recommends -y $JAVA_PACKAGES && \
    ## Cleanup phase.
    add-apt-repository --remove -y ppa:webupd8team/java && \
    apt-get purge -y --auto-remove openjdk* $LAZY_PACK && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk8-installer

ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    JRE_HOME=/usr/lib/jvm/java-8-oracle/jre

COPY rootfs /

EXPOSE 8182

ENTRYPOINT ["/init"]
