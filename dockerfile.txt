# Kerbal Space Program DMP Dedicated Server
#
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Base Image 
FROM mono
#-----------------------------------------------------------------------------------------------------------------------------------------------------------
# Label
LABEL image.authors="Sam10155"
LABEL description="KSP DMP Dedicated Server"
#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Environment Variables
ENV PORTGAME=6702

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Download Server Files
RUN mkdir -p /ksp/setup
ADD https://d-mp.org/builds/release/v0.3.8.5/DMPServer.zip /ksp/setup/
ADD https://d-mp.org/builds/updater/DMPUpdater.exe /ksp

# Setup Server
WORKDIR /ksp/setup
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y zip wine && \
    unzip *.zip -d /ksp/setup && \
    mv -v /ksp/setup/DMPServer/* /ksp

WORKDIR /ksp    
RUN rm -r setup/ && \
    chmod +x DMPServer.exe DMPUpdater.exe

# Run Updater
RUN echo -e "\n" | wine ./DMPUpdater.exe
#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Persistent Data
VOLUME /ksp/Config
VOLUME /ksp/Universe

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Expose Ports
EXPOSE $PORTGAME/tcp

#-----------------------------------------------------------------------------------------------------------------------------------------------------------

# Start Server
ENTRYPOINT ["mono", "./DMPServer.exe" ]
