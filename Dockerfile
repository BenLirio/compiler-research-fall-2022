##############################
########## Config ############
##############################
# Runtime extends McSema: https://github.com/lifting-bits/mcsema
ARG RUNTIME_BASE=public.ecr.aws/e2k5g4z0/mcsema:llvm10-ubuntu18.04-amd64
ARG BUILD_BASE=ubuntu:18.04

##############################
##### Build Dependencies #####
##############################
FROM ${BUILD_BASE} as build-dependencies
ENV ARTIFACT_DOMAIN=artifacts-compiler-research-fall-2022.s3-website-us-east-1.amazonaws.com
ENV LLVM_DIST=clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04
ENV IDA_DIST=ida

ADD http://${ARTIFACT_DOMAIN}/${LLVM_DIST}.tar.xz /artifacts/
ADD http://${ARTIFACT_DOMAIN}/${IDA_DIST}.tar.gz.enc /artifacts/
COPY ida-src.key /

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install xz-utils -y
## Bootstrap Dependencies
RUN apt-get install openssl wget python3 -y
## (optional) Program tools
RUN apt-get install vim clang -y

##############################
########## Build #############
##############################
FROM build-dependencies as build
RUN unxz /artifacts/${LLVM_DIST}.tar.xz
RUN tar xf /artifacts/${LLVM_DIST}.tar -C /artifacts && mv /artifacts/${LLVM_DIST} /artifacts/llvm
RUN openssl enc -d -aes-256-cbc -in /artifacts/${IDA_DIST}.tar.gz.enc -out /artifacts/${IDA_DIST}.tar.gz -kfile /ida-src.key -iter 3
RUN gunzip /artifacts/${IDA_DIST}.tar.gz
RUN tar xf /artifacts/${IDA_DIST}.tar -C /artifacts

##############################
##### Run Dependencies #######
##############################
FROM ${RUNTIME_BASE} as runtime-dependencies
RUN apt-get update -y && apt-get upgrade -y
COPY --from=build /artifacts/llvm /llvm
COPY --from=build /artifacts/ida /ida
## (optional) Program tools
RUN apt-get install vim clang -y

##############################
########## Run ###############
##############################
FROM runtime-dependencies
ENTRYPOINT "/bin/bash"
