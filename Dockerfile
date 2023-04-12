FROM amazonlinux:2022 as builder

ARG GIT_VERSION=2.40.0
ARG GIT_LFS_VERSION=3.3.0
ARG BUILDPLATFORM

# install build dependencies
RUN yum -y install gcc make curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker autoconf tar gzip glibc-langpack-en

# build git from source
RUN mkdir -p /home/build && \
    pushd /home/build && \
    curl -o git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar xzf git.tar.gz && \
    pushd git-${GIT_VERSION} && \
    make configure && \
    ./configure --prefix=/usr/local && \
    make -j $(nproc) all &&  \
    make install && \
    popd && \
    rm -rf *

# download and install git-lfs from
RUN if [ "$BUILDPLATFORM" == "linux/arm64" ]; then arch=arm64; else arch=amd64; fi && \
    curl -o git-lfs.tar.gz -L https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-${arch}-v${GIT_LFS_VERSION}.tar.gz && \
    tar xf git-lfs.tar.gz && \
    mv git-lfs-${GIT_LFS_VERSION}/git-lfs /usr/local/bin/

FROM amazonlinux:2022
COPY --from=builder /usr/local /usr/local/
RUN git lfs install && \
    yum -y install openssh-clients
