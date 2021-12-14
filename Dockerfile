ARG VERSION=1.0

FROM ubuntu:latest

LABEL maintainer="trinity@nebulousanchor.space"
LABEL version=$VERSION

ENV AWS_HOME="/root/aws"
ENV AWS_SRC="/root/aws/aws_inf"
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && yes | apt-get install -y \
    git \
    curl \
    unzip \
    less \
    npm \
    dpkg \
    groff \
    python3 \
    python3-pip \
    locales

RUN mkdir -p aws-cli

WORKDIR aws-cli
RUN locale-gen en_US.UTF-8
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

VOLUME ${AWS_HOME}

USER root

WORKDIR ${AWS_SRC}
ADD ./src/aws_inf ${AWS_SRC}
RUN npm cache clean -f && \
    npm install -g n && \
    n stable
RUN npm install -g aws-cdk
RUN pip install -r requirements.txt
RUN python3 -m pip install --upgrade pip
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb
RUN chmod +x auto_gather.sh



CMD ["/bin/bash"]