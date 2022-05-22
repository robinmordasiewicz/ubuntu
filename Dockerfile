FROM ubuntu:latest

ENV TZ="America/Toronto"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get --yes update \
    && apt-get --yes upgrade \
    && apt-get -y install apt-utils \
    && apt-get -y install net-tools dnsutils iputils-ping iproute2 net-tools ethtool curl vim sudo gnupg2 jq git

RUN . /etc/os-release \
    && echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list \
    && curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | apt-key add - \
    && apt-get update \
    && apt-get -y install skopeo

RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \
    && chmod +x /usr/local/bin/argocd

RUN apt-get install -y apt-transport-https ca-certificates curl \
    && curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get --yes update \
    && apt-get install -y kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && rm get_helm.sh \
    && helm repo add robinmordasiewicz https://robinmordasiewicz.github.io/helm-charts \
    && helm repo update

RUN groupadd -g 1000 ubuntu
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g 1000 -G sudo -u 1000 ubuntu
RUN touch /home/ubuntu/.sudo_as_admin_successful
RUN touch /home/ubuntu/.hushlogin
RUN chown -R ubuntu:ubuntu /home/ubuntu
USER ubuntu:ubuntu
