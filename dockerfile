FROM node:20.12.1-alpine3.18
LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

ENV USER=bbe
ENV UID=10000

ENV GRADLE_VERSION 8.3
ENV GRADLE_HOME /opt/gradle

RUN apk update \
    && apk upgrade \
    && apk add --no-cache openjdk11-jre \
        git \
        bash \
        tzdata \
        curl \
        #openssl=3.1.5-r0 \
        openssl \
        busybox \    
       # busybox=1.36.1-r6 \
        libcrypto1.1 \
        ssl_client \
        zlib \
        libretls \ 
        libssl1.1 \
    && cp /usr/share/zoneinfo/America/Lima /etc/localtime \
    && echo "America/Lima" >  /etc/timezone \
    && rm -rf /var/cache/apk/*

# Verificar la versión de busybox instalada
RUN apk info -vv busybox
RUN apk list busybox

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

RUN apk add --update ttf-dejavu ca-certificates msttcorefonts-installer ttf-liberation fontconfig \
    && update-ms-fonts && fc-cache -f \
    && rm -rf /var/cache/apk/* 

RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam \
  && apk add bash sudo shadow \
  && apk del .pipeline-deps


CMD [ "node" ]