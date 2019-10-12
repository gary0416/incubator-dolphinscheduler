#!/bin/bash

if [ -n "$DS_PROXY" ]; then
  sed -i "s/127.0.0.1:12345/$DS_PROXY/g" /etc/nginx/conf.d/default.conf
fi

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
