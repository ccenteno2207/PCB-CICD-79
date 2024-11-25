FROM ubuntu:rolling

LABEL org.opencontainers.image.authors="BCP - Matrix"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade && apt-get -y install --no-install-recommends \
  ca-certificates \
  curl \
  bash \
  npm \
  tar \
  gnupg \
  systemd \
  jq && \
  apt-get clean && \
  # ca-certificates=20240203 \
  # curl=8.9.1-2ubuntu2 \
  # bash=5.2.32-1ubuntu1 \
  # npm=9.2.0~ds1-3 \
  # tar=1.35+dfsg-3build1 \
  # gnupg=2.4.4-2ubuntu18 \
  # systemd=256.5-2ubuntu3 \
  # jq=1.7.1-3build1 && \
  # apt-get clean && \
  rm -rf /var/lib/apt/lists/*


# Instalar Maven
RUN apt-get update && \
    apt-get install -y --no-install-recommends maven=3.8.8-1 && \
    rm -rf /var/lib/apt/lists/*

# instalando nodejs
RUN  apt-get update && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key |  gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  NODE_MAJOR=20 && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt-get update && \
  apt-get install -qq --no-install-recommends \
    nodejs=20.18.0-1nodesource1 &&  \
  rm -rf /var/lib/apt/lists/* && \
  npm install -g snyk@1.1294.0


# COPY init.sh /usr/bin/init.sh
# RUN chmod +x /usr/bin/init.sh

WORKDIR /app
ENTRYPOINT [ "/usr/bin/init.sh" ]