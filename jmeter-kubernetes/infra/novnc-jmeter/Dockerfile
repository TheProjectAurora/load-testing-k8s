FROM dorowu/ubuntu-desktop-lxde-vnc:focal

###########################################################################
# NoVNC Setup + Microsoft Visual Studio Code installation with plugins
ENV DEBIAN_FRONTEND=noninteractive DONT_PROMPT_WSL_INSTALL=true
RUN set -xe \
    && wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt -qq update && apt dist-upgrade -y \
    && apt install -qq --no-install-recommends --allow-unauthenticated -y \
      git \ 
      code \
      npm  \
      unzip \
      nano \
      openjdk-8-jre \
      bash-completion \
      python3-pip \
    && apt clean && rm -rf /var/lib/apt/lists/* 
# GENERATE SSL CERT
COPY novnc_openssl.cnf /etc/nginx/ssl/novnc_openssl.cnf
RUN set -xe \
    && openssl req -x509 -config /etc/nginx/ssl/novnc_openssl.cnf -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
EXPOSE 443
# ADD coder USER
# SOURCE: https://github.com/eficode-academy/code-server/blob/master/docker-images/Dockerfile
# Set password and other coder user things are handled with noVNC environment parameters in docker-compose.yaml
RUN set -xe \
    && adduser --gecos '' --disabled-password coder \
    && set -xe  && usermod -a -G sudo coder
USER coder
ENV HOME=/home/coder
WORKDIR /home/coder
# TODO: Create loop that install extensions
RUN set -xe && \
    code --verbose --log debug --install-extension redhat.vscode-yaml
#TODO: NoVNC binary should be executed under root, under coder it not work

RUN echo 'source <(kubectl completion bash)' >>~/.bashrc
###########################################################################
# TOOLING
#####
USER root
# Install kubectl
ENV K8S_VERSION=v1.20.5
RUN curl -sSL https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl > /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install kubectl krew: https://krew.sigs.k8s.io/
RUN curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.4.1/krew.tar.gz" && \
    tar zxvf krew.tar.gz && \
    ./krew-linux_amd64 install krew && \
    rm -Rf krew*
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/coder/.krew/bin
# Install kubectl neat: https://github.com/itaysk/kubectl-neat
RUN /usr/local/bin/kubectl krew install neat

# Install helm
ENV HELM_HOME=/root/.helm
ENV HELM_VERSION=v3.5.4
RUN curl -sSL https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | sudo tar -xz -C /usr/local/bin linux-amd64/helm --strip-components=1 && \
    helm completion bash > /etc/bash_completion.d/helm

# INSTALL: https://jmeter.apache.org/
RUN set -xe && \
    export JMETER_VERSION=5.4.1 && \
    cd / && \
    wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-$JMETER_VERSION.tgz && \
    tar -xzf apache-jmeter-$JMETER_VERSION.tgz && \
    sudo ln -s /apache-jmeter-${JMETER_VERSION}/bin/jmeter.sh /usr/bin/jmeter.sh && \
    cd /apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/JMeterPlugins-Standard-1.4.0.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.4.0.zip && unzip -n /tmp/JMeterPlugins-Standard-1.4.0.zip && rm /tmp/JMeterPlugins-Standard-1.4.0.zip && \
    cd /apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/bzm-parallel-0.10.zip https://jmeter-plugins.org/files/packages/bzm-parallel-0.10.zip && \
    cd /apache-jmeter-$JMETER_VERSION/ && wget -q -O /tmp/jpgc-casutg-2.9.zip  https://jmeter-plugins.org/files/packages/jpgc-casutg-2.9.zip && unzip -n /tmp/jpgc-casutg-2.9.zip && rm /tmp/jpgc-casutg-2.9.zip && \
    unzip -n /tmp/bzm-parallel-0.10.zip && rm /tmp/bzm-parallel-0.10.zip && \
    sudo chmod +x /usr/bin/jmeter.sh && \
    sudo ln -s /usr/bin/jmeter.sh /usr/bin/jmeter

