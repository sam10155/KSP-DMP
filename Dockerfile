FROM debian:bookworm-20241016-slim

WORKDIR /root

ENV PORTGAME=6702

# ARG only available during build
ARG DEBIAN_FRONTEND=noninteractive
ARG WINEBRANCH=stable
ARG WINEVERSION=9.0.0.0~bookworm-1

ENV WINEARCH=win64
ENV WINEDEBUG=-all
ENV WINEPREFIX=/root/server
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN \
  dpkg --add-architecture i386 && \
  apt-get -qq -y update && \
  apt-get upgrade -y -qq && \
  apt-get install -y -qq software-properties-common curl gnupg2 wget && \
  # add repository keys
  mkdir -pm755 /etc/apt/keyrings && \
  wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key && \
  # add repositories
  echo "deb http://ftp.us.debian.org/debian bookworm main non-free" > /etc/apt/sources.list.d/non-free.list && \
  wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
RUN \
  apt-get update -qq && \
  apt-get install -qq -y \
  winehq-${WINEBRANCH}=${WINEVERSION} \
  wine-${WINEBRANCH}-i386=${WINEVERSION} \
  wine-${WINEBRANCH}-amd64=${WINEVERSION} \
  steamcmd \
  xvfb \
  cabextract && \
  curl -L https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > /usr/local/bin/winetricks && \
  chmod +x /usr/local/bin/winetricks 

# Install DMPServer and update
COPY DMPUpdater.exe /ksp/
COPY DMPServer.zip /ksp/setup/
RUN \
  mkdir -p /ksp/setup && \
  cd /ksp/setup && \
  wine DMPUpdater.exe

# Clean up and set permissions
RUN \
  cd /ksp && \
  rm -r setup/ && \
  chmod +x DMPServer.exe DMPUpdater.exe

# Set working directory and expose ports
WORKDIR /ksp
EXPOSE $PORTGAME/tcp

# Set entrypoint to run the server
ENTRYPOINT [ "wine", "DMPServer.exe" ]
