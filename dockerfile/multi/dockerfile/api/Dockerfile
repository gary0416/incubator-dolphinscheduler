# docker build -t --build-arg version=1.1.0 gary0416/dolphinscheduler-api:1.1.0 .
ARG version

FROM gary0416/dolphinscheduler-common:${version}

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get update && \
    apt-get -y install mysql-client-5.7 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e "$ a [client]"  /etc/mysql/my.cnf && \
    sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf

EXPOSE 12345

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["api"]