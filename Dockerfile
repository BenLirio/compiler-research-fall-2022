# Build config
ARG RUNTIME_BASE=public.ecr.aws/e2k5g4z0/mcsema:llvm10-ubuntu20.04-amd64
ARG BUILD_BASE=ubuntu:20.04


# 1. Builds IDA

# Download encrypted IDA and build dependencies
FROM ${BUILD_BASE} as build-dependencies
ENV ARTIFACT_DOMAIN=artifacts-compiler-research-fall-2022.s3-website-us-east-1.amazonaws.com
ENV IDA_DIST=ida
ADD http://${ARTIFACT_DOMAIN}/${IDA_DIST}.tar.gz.enc /artifacts/
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install openssl clang -y
COPY ida-src.key /

RUN mkdir -p /opt/CLI11
ADD https://github.com/CLIUtils/CLI11/releases/download/v2.2.0/CLI11.hpp /opt/CLI11/


# Unencrypt and extract IDA
FROM build-dependencies as build
RUN openssl enc -d -aes-256-cbc -in /artifacts/${IDA_DIST}.tar.gz.enc -out /artifacts/${IDA_DIST}.tar.gz -kfile /ida-src.key -iter 3
RUN gunzip /artifacts/${IDA_DIST}.tar.gz
RUN tar xf /artifacts/${IDA_DIST}.tar -C /artifacts

COPY src src
RUN clang++ /src/lift/main.cpp -o /artifacts/lift



# 2. Setup Runtime

# Copy IDA from build stage
FROM ${RUNTIME_BASE} as runtime-dependencies
RUN apt-get update -y && apt-get upgrade -y
COPY --from=build /artifacts/ida /ida
COPY ida.reg /root/.idapro/
# Update protobuf
RUN sed -i 's/3.15.0/3.20.0/g' /opt/trailofbits/lib/python3/site-packages/mcsema_disass-3.1.3.8-py3.8.egg/EGG-INFO/requires.txt
RUN pip3 install protobuf==3.20.0
# Development is done inside this container so vim and clang are useful
RUN apt-get install vim clang -y
COPY --from=build /artifacts/lift /usr/bin/lift

# Copy source code and enter bash
FROM runtime-dependencies
RUN /ida/idapyswitch --auto-apply
COPY runtime runtime
WORKDIR runtime
ENTRYPOINT /bin/bash
