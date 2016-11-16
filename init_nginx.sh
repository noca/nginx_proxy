#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: init_nginx.sh <NGINX INSTALL DIR>"
    exit 1
fi

apt-get install lua50 liblua50

idir=$1

wget -O ngx_lua_module.tar.gz -c https://github.com/openresty/lua-nginx-module/archive/v0.10.6.tar.gz
tar xvzf ngx_lua_module.tar.gz

wget -O dev_tk.tar.gz -c https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz
tar xvzf dev_tk.tar.gz

wget -O nginx.tar.gz  -c http://nginx.org/download/nginx-1.10.2.tar.gz
tar xvzf nginx.tar.gz
cd nginx-1.10.2
./configure --prefix=$idir --with-http_sub_module --with-http_ssl_module --add-module=../ngx_devel_kit-0.3.0 --add-module=../lua-nginx-module-0.10.6 && make && make install

cd ..

mkdir -p $idir/conf/enabled
cp nginx.conf $idir/conf/nginx.conf


