# Configuration
ARG UBUNTU_VERSION=20.04

# Base Images
ARG RUNTIME_BASE=ubuntu:${UBUNTU_VERSION}
ARG BUILD_BASE=ubuntu:${UBUNTU_VERSION}

# Dependencies
FROM ${RUNTIME_BASE} as runtime-dependencies
RUN apt-get update -y && apt-get upgrade -y && apt-get install openssl wget python3 python3-pip -y

FROM ${BUILD_BASE} as build-dependencies

# Build
FROM build-dependencies as build

# Run
FROM runtime-dependencies
COPY scripts scripts
CMD ["/bin/bash"]
