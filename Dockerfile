ARG VERSION=1.0

FROM alpine:3.15

LABEL maintainer="trinity@nebulousanchor.space"
LABEL version=$VERSION

ENV AWS_HOME="/root/aws"
ENV AWS_SRC="/root/aws/aws_inf"

RUN apk add --no-cache \
    bash \
    acl \
    fcgi \
    file \
    gettext \
    git \
    curl \
    unzip\
    python3-dev \
    py3-pip \
    gcc \
    linux-headers \
    musl-dev \
    libffi-dev \
    openssl-dev \
    less \
    groff \
    npm \
    su-exec \
    zlib-dev \
    make \
    cmake

RUN git clone --recursive  --depth 1 --branch v2 --single-branch  https://github.com/aws/aws-cli.git

WORKDIR aws-cli

RUN pip install -r requirements.txt
RUN pip install -e .

VOLUME ${AWS_HOME}

USER root

WORKDIR ${AWS_SRC}
ADD ./src/aws_inf ${AWS_SRC}
RUN npm install -g aws-cdk
RUN pip3 install -r requirements.txt
RUN python3 -m pip install --upgrade pip
RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
RUN su-exec session-manager-plugin.deb


CMD ["/bin/bash"]