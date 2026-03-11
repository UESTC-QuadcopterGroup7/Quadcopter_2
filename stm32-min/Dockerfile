FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    cmake \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    gdb-multiarch \
    openocd \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work