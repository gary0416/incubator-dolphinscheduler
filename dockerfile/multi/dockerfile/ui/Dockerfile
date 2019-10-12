# docker build --build-arg version=test-20191011-1831 -t gary0416/dolphinscheduler-ui:1.1.0 .
FROM node:8-slim as builder

ARG version

RUN cd /opt && \
    wget https://github.com/gary0416/incubator-dolphinscheduler/archive/${version}.tar.gz && \
    tar -zxvf ${version}.tar.gz && \
    mv incubator-dolphinscheduler-${version} easyscheduler-source && \
    rm -rf ./${version}.tar.gz && \
    cd /opt/easyscheduler-source/escheduler-ui && \
    npm install node-sass --unsafe-perm && \
    npm install && \
    npm run build && \
    npm cache clean -f && \
    mv /opt/easyscheduler-source/escheduler-ui/dist /opt/escheduler-ui && \
    mv /opt/easyscheduler-source/dockerfile/conf/nginx/default.conf /opt/escheduler-ui/default.conf && \
    rm -rf /opt/easyscheduler-source

# dolphinscheduler-ui image
FROM nginx:mainline

COPY --from=builder /opt/escheduler-ui /opt/escheduler-ui
COPY docker-entrypoint.sh /usr/local/bin/

RUN mv /opt/escheduler-ui/default.conf /etc/nginx/conf.d/default.conf && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8888

ENTRYPOINT ["docker-entrypoint.sh"]