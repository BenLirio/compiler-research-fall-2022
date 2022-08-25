##############################
########## Config ############
##############################
# Runtime extends McSema: https://github.com/lifting-bits/mcsema
ARG RUNTIME_BASE=ghcr.io/lifting-bits/mcsema/mcsema-llvm10-ubuntu20.04-amd64
ARG BUILD_BASE=ubuntu:20.04



##############################
##### Run Dependencies #######
##############################
FROM ${RUNTIME_BASE} as runtime-dependencies
RUN apt-get update -y && apt-get upgrade -y
## Bootstrap Dependencies
RUN apt-get install openssl wget python3 -y
## (optional) Program tools
RUN apt-get install vim clang -y
## (fix) Update deprecated protobuf version
RUN sed -i 's/3.2.0/3.20.1/g' /opt/trailofbits/lib/python3/site-packages/mcsema_disass-3.1.3.8-py3.8.egg/EGG-INFO/requires.txt
RUN pip3 install protobuf==3.20.1



##############################
##### Build Dependencies #####
##############################
FROM ${BUILD_BASE} as build-dependencies



##############################
########## Build #############
##############################
FROM build-dependencies as build




##############################
########## Run ###############
##############################
FROM runtime-dependencies
COPY scripts scripts
CMD ["/bin/bash"]
