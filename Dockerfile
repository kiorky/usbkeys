FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
ADD ./apt.txt ./
RUN apt update && apt install -y  $(grep -Ev "^#" apt.txt) && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
WORKDIR /app
RUN mkdir usbmount
ADD ./*sh ./
