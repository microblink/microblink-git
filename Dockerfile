FROM centos:7 as builder

ARG GIT_VERSION=2.25.0
ARG GIT_LFS_VERSION=2.9.2

# install build dependencies
RUN yum -y install gcc make curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker autoconf

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
RUN curl -o git-lfs.tar.gz -L https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VERSION}/git-lfs-linux-amd64-v${GIT_LFS_VERSION}.tar.gz && \
    tar xf git-lfs.tar.gz && \
    mv git-lfs /usr/local/bin/

FROM centos:7
COPY --from=builder /usr/local /usr/local/
RUN git lfs install && \
    yum -y install openssh-clients
