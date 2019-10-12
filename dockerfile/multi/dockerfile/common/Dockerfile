# docker build --build-arg version=test-20191011-1831 --build-arg ds_version=1.1.0-SNAPSHOT -t gary0416/dolphinscheduler-common:1.1.0 .
# for master-server/worker-server and logger-server/alert-server
FROM maven:3.6.2-jdk-8-slim as builder

ARG version
ARG ds_version

RUN apt-get update && \
    apt-get -y install wget && \
    cd /opt && \
    wget https://github.com/gary0416/incubator-dolphinscheduler/archive/${version}.tar.gz && \
    tar -zxvf ${version}.tar.gz && \
    mv incubator-dolphinscheduler-${version} dolphinscheduler-source && \
    rm -rf ./${version}.tar.gz && \
    cd /opt/dolphinscheduler-source && \
    mvn -U clean package assembly:assembly -Dmaven.test.skip=true && \
    rm -rf /root/.m2 && \
    mkdir -p /opt/escheduler && \
    tar -zxvf /opt/dolphinscheduler-source/target/escheduler-${ds_version}.tar.gz -C /opt/escheduler && \
    rm -rf /opt/escheduler/conf && \
    mv /opt/dolphinscheduler-source/dockerfile/conf/escheduler/conf /opt/escheduler/conf && \
    rm -rf /opt/dolphinscheduler-source


FROM ubuntu:18.04

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

RUN apt-get update && \
    apt-get -y install \
    tzdata \
    wget \
    openjdk-8-jdk \
    sudo \
    python \
    vim \
    iputils-ping \
    net-tools \
    openssh-server \
    python-pip \
    netcat-openbsd \
    iproute2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    echo "Asia/Shanghai" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    pip install kazoo

COPY --from=builder /opt/escheduler /opt/escheduler
COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
  chmod +x /opt/escheduler/script/create-escheduler.sh && \
  chmod +x /opt/escheduler/bin/escheduler-daemon.sh && \
  rm -rf /bin/sh && \
  ln -s /bin/bash /bin/sh && \
  mkdir -p /tmp/xls

# port for master-server/worker-server and logger-server/alert-server
EXPOSE 5566 7788 50051 7789

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["help"]