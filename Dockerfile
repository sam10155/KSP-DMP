# Kerbal Space Program DMP Dedicated Server
FROM mono

LABEL image.authors="Sam10155"
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
    apt install -y zip wine wine32 && \
    unzip *.zip -d /ksp/setup && \
    mv -v /ksp/setup/DMPServer/* /ksp

WORKDIR /ksp
RUN rm -r setup/ && \
    chmod +x DMPServer.exe DMPUpdater.exe

# Run Updater with Wine
RUN wine ./DMPUpdater.exe

VOLUME /ksp/Config
VOLUME /ksp/Universe

EXPOSE $PORTGAME/tcp

ENTRYPOINT ["mono", "./DMPServer.exe"]
