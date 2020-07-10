FROM ubuntu
ARG env=DEBUG
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y make gcc pkg-config flex bison libpng-dev git
RUN git clone -b v0.4.0 --depth=1 https://github.com/rednex/rgbds
RUN make -C rgbds CGLAGS=-O2 install

WORKDIR /examples
COPY makefile .
COPY res res
COPY src src
RUN make