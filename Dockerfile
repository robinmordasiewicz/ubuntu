FROM ubuntu:latest

RUN apt-get --yes update \
    && apt-get --yes upgrade \
    && apt -y install net-tools dnsutils
