#!/bin/bash
# 未取消的模块：access、gzip、rewrite、proxy、http_limit_req、http_upstream_ip_hash、upstream_least_conn、http_upstream_keepalive、stream_return
set -ex;

NGINX_VERSION=${NGINX_VERSION:-1.19.8};
CONFIG="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --without-select_module \
    --without-poll_module \
    --without-http_charset_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_auth_basic_module \
    --without-http_mirror_module \
    --without-http_autoindex_module \
    --without-http_status_module \
    --without-http_geo_module \
    --without-http_map_module \
    --without-http_split_clients_module \
    --without-http_referer_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_grpc_module \
    --without-http_memcached_module \
    --without-http_limit_conn_module \
    --without-http_empty_gif_module \
    --without-http_browser_module \
    --without-http_upstream_hash_module \
    --without-http_upstream_random_module \
    --without-http_upstream_zone_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-stream_limit_conn_module \
    --without-stream_geo_module \
    --without-stream_map_module \
    --without-stream_split_clients_module \
    --without-stream_upstream_hash_module \
    --without-stream_upstream_random_module \
    --without-stream_upstream_zone_module \
    --with-openssl-opt=enable-ec_nistp_64_gcc_128 \
";
CC_OPTS=--with-cc-opt="-Ofast -fstack-protector -fpic -m64 -gsplit-dwarf";
LD_OPTS=--with-ld-opt="-fpie -pie -flto -Wl,-z,relro -Wl,-z,now -Wl,--as-needed";

curl -L https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar xzf -;
cd ./nginx-$NGINX_VERSION;
sed -i -e '/NGX_CLANG_OPT="-O"/d' -e '/CFLAGS="$CFLAGS -g"/d' ./auto/cc/clang;
./configure $CONFIG "$CC_OPTS" "$LD_OPTS";
make -sj$(nproc);
strip -s ./objs/nginx;
upx -9 ./objs/nginx;
cp ./objs/nginx ../;
