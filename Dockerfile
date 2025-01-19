# Kerbal Space Program DMP Dedicated Server
FROM mono

LABEL description="KSP DMP Dedicated Server"

ENV PORTGAME=6702

RUN mkdir -p /ksp/setup
ADD https://d-mp.org/builds/release/v0.3.8.5/DMPServer.zip /ksp/setup/
ADD https://d-mp.org/builds/updater/DMPUpdater.exe /ksp

WORKDIR /ksp/setup
RUN apt update -y && \
    apt upgrade -y && \
    dpkg --add-architecture i386 && \
    apt update -y && \
    apt install -y zip && \
    unzip *.zip -d /ksp/setup && \
    mv -v /ksp/setup/DMPServer/* /ksp

# Install necessary dependencies
RUN apt-get update -y \
    && apt-get install -y wget curl gnupg2 software-properties-common \
    && apt-get install -y mono-complete xvfb \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

WORKDIR /ksp
RUN rm -r setup/ && \
    chmod +x DMPServer.exe DMPUpdater.exe

# Run Updater
RUN xvfb-run mono ./DMPUpdater.exe

VOLUME /ksp/Config
VOLUME /ksp/Universe

EXPOSE $PORTGAME/tcp

ENTRYPOINT ["mono", "./DMPServer.exe"]

