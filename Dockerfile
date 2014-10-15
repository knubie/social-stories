FROM ubuntu:14.04

RUN apt-get -qq update
# install build dependencies
RUN apt-get -qqy install libreadline-dev libncurses5-dev libpcre3-dev \
  libssl-dev perl make curl git-core luarocks # dnsmasq

# build/install OpenResty
ENV SRC_DIR /usr/local
ENV OPENRESTY_VERSION 1.7.4.1
ENV OPENRESTY_PREFIX /usr/local/openresty
ENV LAPIS_VERSION 1.0.5

RUN cd $SRC_DIR && \
  curl -LO http://openresty.org/download/ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
  tar xzf ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
  cd ngx_openresty-$OPENRESTY_VERSION && \
  ./configure --prefix=$OPENRESTY_PREFIX --with-luajit --with-http_realip_module && \
  make && make install && rm -rf ngx_openresty-$OPENRESTY_VERSION*

RUN luarocks install --server=http://rocks.moonscript.org/manifests/leafo \
  lapis $LAPIS_VERSION
RUN luarocks install moonscript
RUN luarocks install pgmoon
RUN luarocks install LuaBitOp
RUN luarocks install lapis-console
RUN luarocks install lustache
# Missing dependencies for lapis:
# lpeg
# etlua
# loadkit
# lua-cjson
# ansicolors
# luasocket

# Missing dependencies for moonscript:
# luafilesystem >= 1.5
# alt-getopt >= 0.7

# Unset ENV
RUN unset SRC_DIR OPENRESTY_VERSION OPENRESTY_PREFIX LAPIS_VERSION

WORKDIR /code

RUN lapis migrate production
