FROM phusion/baseimage:noble-1.0.0 as builder

ARG GIT_VERSION=2.45.1
ARG GIT_LFS_VERSION=3.5.1
ARG BUILDPLATFORM

# install build dependencies
RUN apt update && apt upgrade -y
RUN apt install -y gcc make libcurl4-openssl-dev autoconf zlib1g-dev gettext

# make sure bash is used for following RUN commands
RUN ln -f -s /usr/bin/bash /bin/sh

# build git from source
RUN mkdir -p /home/build && \
    pushd /home/build && \
    curl -o git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar xzf git.tar.gz && \
    pushd git-${GIT_VERSION} && \
    make configure && \
    ./configure --prefix=/usr/local --without-tcltk && \
    make -j $(nproc) all &&  \
    make install && \
    popd && \
    rm -rf *

# download and install git-lfs from
RUN if [ "$BUILDPLATFORM" == "linux/arm64" ]; then arch=arm64; else arch=amd64; fi && \
    curl -o git-lfs.tar.gz -L https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${arch}-v${GIT_LFS_VERSION}.tar.gz && \
    tar xf git-lfs.tar.gz && \
    mv git-lfs-${GIT_LFS_VERSION}/git-lfs /usr/local/bin/

FROM phusion/baseimage:noble-1.0.0

COPY --from=builder /usr/local /usr/local/

RUN git lfs install
