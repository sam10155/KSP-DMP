# Use the official Mono image
FROM mono:latest

# Install dependencies for Wine, Xvfb, and Wine Mono
RUN apt-get update -y && apt-get install -y \
    wine xvfb wine-mono \
    && dpkg --add-architecture i386 \
    && apt-get update -y

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
