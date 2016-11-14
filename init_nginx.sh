#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: init_nginx.sh <NGINX INSTALL DIR>"
    exit 1
fi

idir=$1

wget -O nginx.tar.gz  -c http://nginx.org/download/nginx-1.10.2.tar.gz

tar xvzf nginx.tar.gz

cd nginx-1.10.2
./configure --prefix=$idir --with-http_sub_module --with-http_ssl_module && make && make install

cd ..

mkdir -p $idir/conf/enabled
cp nginx.conf $idir/conf/nginx.conf


