# Use the official Mono image
FROM mono:latest

# Add WineHQ repository and install Wine and dependencies
RUN dpkg --add-architecture i386 \
    && apt-get update -y \
    && apt-get install -y \
    wget curl gnupg2 software-properties-common \
    && curl -fsSL https://dl.winehq.org/wine-builds/Release.key | apt-key add - \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/debian/ buster main' \
    && apt-get update -y \
    && apt-get install -y \
    winehq-stable \
    xvfb \
    wine-mono \
    && rm -rf /var/lib/apt/lists/*

# Add DMPServer.zip and DMPUpdater.exe to the container
ADD https://d-mp.org/builds/release/v0.3.8.5/DMPServer.zip /ksp/setup/
ADD https://d-mp.org/builds/updater/DMPUpdater.exe /ksp

# Set the working directory to /ksp/setup
WORKDIR /ksp/setup

# Run the DMPUpdater using Wine with Xvfb to simulate an X server
RUN xvfb-run wine ./DMPUpdater.exe

# Set the working directory to /ksp to perform further setup actions
WORKDIR /ksp

# Clean up the setup directory and make sure the server files are executable
RUN rm -r setup/ && chmod +x DMPServer.exe DMPUpdater.exe

# Expose necessary ports for the server (adjust according to your needs)
EXPOSE 6700

# Set the entry point to run the DMPServer.exe when the container starts
CMD ["wine", "./DMPServer.exe"]
