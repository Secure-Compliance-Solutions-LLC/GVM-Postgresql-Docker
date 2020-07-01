FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /postgresql.asc

RUN apt-get update && \
	apt-get install -y \
	cmake \
	gnupg \
	libglib2.0-dev \
	libgnutls28-dev \
	libgpgme-dev \
	libhiredis-dev \
	libssh-gcrypt-dev \
	libxml2-dev \
	pkg-config \
	wget && \
	echo "deb http://apt.postgresql.org/pub/repos/apt focal-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
	apt-key add /postgresql.asc && \
	apt-get update && \
	apt-get install -y \
	postgresql-12 \
	postgresql-server-dev-12 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV gvm_libs_version="v11.0.1"

    #
    # install libraries module for the Greenbone Vulnerability Management Solution
    #
    
RUN mkdir /build && \
    cd /build && \
    wget --no-verbose https://github.com/greenbone/gvm-libs/archive/$gvm_libs_version.tar.gz && \
    tar -zxf $gvm_libs_version.tar.gz && \
    cd /build/*/ && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    make install && \
    cd / && \
    rm -rf /build

COPY start.sh /

ENTRYPOINT ["/start.sh"]
