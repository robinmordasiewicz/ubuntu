FROM ubuntu:latest

RUN apt-get --yes update \
    && apt-get --yes upgrade \
    && apt -y install net-tools dnsutils iputils-ping iproute2 net-tools ethtool curl vim

RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \
    && chmod +x /usr/local/bin/argocd
