# Dolphin Scheduler on Docker

[dockerfiles](https://github.com/gary0416/incubator-dolphinscheduler/tree/test-docker/dockerfile/multi)

## Supported tags and respective Dockerfile links
[test-20191011-1831](https://github.com/gary0416/incubator-dolphinscheduler/tree/test-docker/dockerfile/multi)

example:
```
version: '3'

networks:
  dolphinscheduler:
    driver: bridge

services:
  mysql:
    container_name: dolphinscheduler-mysql
    image: mysql:5.7.25
    restart: always
    networks:
      - dolphinscheduler
    environment:
      MYSQL_DATABASE: escheduler
      MYSQL_ROOT_PASSWORD: root@123
    command: [
      '--bind-address=0.0.0.0',
      '--character-set-server=utf8mb4',
      '--collation-server=utf8mb4_unicode_ci',
      '--default-time-zone=+8:00'
    ]
    ports:
      - 3306:3306
    volumes:
      - ./data/mysql:/var/lib/mysql
  zoo1:
    container_name: dolphinscheduler-zoo1
    image: zookeeper:3.4.14
    restart: always
    hostname: zoo1
    networks:
      - dolphinscheduler
    ports:
      - 2181:2181
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888
    volumes:
      - ./data/zoo1/data:/data
      - ./data/zoo1/datalog:/datalog
  dolphinscheduler-ui:
    container_name: dolphinscheduler-ui
    image: gary0416/dolphinscheduler-ui:1.1.0
    restart: always
    networks:
      - dolphinscheduler
    environment:
      DS_PROXY: 192.168.xx.xx:12345
    ports:
      - 8888:8888
  dolphinscheduler-api:
    container_name: dolphinscheduler-api
    image: gary0416/dolphinscheduler-api:1.1.0
    restart: always
    networks:
      - dolphinscheduler
    depends_on:
      - mysql
      - zoo1
    environment:
      ZK_HOST: 192.168.xx.xx
      ZK_PORT: 2181
      MYSQL_HOST: 192.168.xx.xx
      MYSQL_PORT: 3306
      MYSQL_ROOT_PWD: root@123
      ESZ_DB: escheduler
    command: api
    ports:
      - 12345:12345
    volumes:
      - ./data/logs:/opt/escheduler/logs
      - ../../conf/escheduler/conf:/opt/escheduler/conf:ro
  dolphinscheduler-master:
    container_name: dolphinscheduler-master
    image: gary0416/dolphinscheduler-common:1.1.0
    restart: always
    networks:
      - dolphinscheduler
    depends_on:
      - dolphinscheduler-api
    environment:
      ZK_HOST: 192.168.xx.xx
      ZK_PORT: 2181
    command: master
    ports:
      - 5566:5566
    volumes:
      - ./data/logs:/opt/escheduler/logs
      - ../../conf/escheduler/conf:/opt/escheduler/conf:ro
  dolphinscheduler-worker:
    container_name: dolphinscheduler-worker
    image: gary0416/dolphinscheduler-common:1.1.0
    restart: always
    network_mode: host
    depends_on:
      - dolphinscheduler-api
    environment:
      ZK_HOST: 192.168.xx.xx
      ZK_PORT: 2181
    command: worker
    ports:
      - 7788:7788
      - 50051:50051
    volumes:
      - ./data/logs:/opt/escheduler/logs
      - ../../conf/escheduler/conf:/opt/escheduler/conf:ro
      - ../../multi/docker-compose/worker/worker-extra-init.sh:/opt/escheduler/script/worker-extra-init.sh
      - /usr/hdp/current/spark2-client:/opt/spark2-client:ro
      - /etc/spark2/2.6.3.0-235/0:/etc/spark2/2.6.3.0-235/0:ro
  dolphinscheduler-alert:
    container_name: dolphinscheduler-alert
    image: gary0416/dolphinscheduler-common:1.1.0
    restart: always
    networks:
      - dolphinscheduler
    environment:
      ALERT_SERVER_STARTUP_DELAY: 180
    command: alert
    ports:
      - 7789:7789
    volumes:
      - ./data/logs:/opt/escheduler/logs
      - ../../conf/escheduler/conf:/opt/escheduler/conf:ro
```

**Rember to modify MySQL config file**

Dolphin Scheduler
============
[![License](https://img.shields.io/badge/license-Apache%202-4EB1BA.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Total Lines](https://tokei.rs/b1/github/apache/Incubator-DolphinScheduler?category=lines)](https://github.com/apache/Incubator-DolphinScheduler)

> Dolphin Scheduler for Big Data

[![Stargazers over time](https://starchart.cc/apache/incubator-dolphinscheduler.svg)](https://starchart.cc/apache/incubator-dolphinscheduler)

[![EN doc](https://img.shields.io/badge/document-English-blue.svg)](README.md)
[![CN doc](https://img.shields.io/badge/文档-中文版-blue.svg)](README_zh_CN.md)


### Design features: 

A distributed and easy-to-expand visual DAG workflow scheduling system. Dedicated to solving the complex dependencies in data processing, making the scheduling system `out of the box` for data processing.
Its main objectives are as follows:

 - Associate the Tasks according to the dependencies of the tasks in a DAG graph, which can visualize the running state of task in real time.
 - Support for many task types: Shell, MR, Spark, SQL (mysql, postgresql, hive, sparksql), Python, Sub_Process, Procedure, etc.
 - Support process scheduling, dependency scheduling, manual scheduling, manual pause/stop/recovery, support for failed retry/alarm, recovery from specified nodes, Kill task, etc.
 - Support process priority, task priority and task failover and task timeout alarm/failure
 - Support process global parameters and node custom parameter settings
 - Support online upload/download of resource files, management, etc. Support online file creation and editing
 - Support task log online viewing and scrolling, online download log, etc.
 - Implement cluster HA, decentralize Master cluster and Worker cluster through Zookeeper
 - Support online viewing of `Master/Worker` cpu load, memory
 - Support process running history tree/gantt chart display, support task status statistics, process status statistics
 - Support backfilling data
 - Support multi-tenant
 - Support internationalization
 - There are more waiting partners to explore


### What's in Dolphin Scheduler

 Stability | Easy to use | Features | Scalability |
 -- | -- | -- | --
Decentralized multi-master and multi-worker | Visualization process defines key information such as task status, task type, retry times, task running machine, visual variables and so on at a glance.  |  Support pause, recover operation | support custom task types 
HA is supported by itself | All process definition operations are visualized, dragging tasks to draw DAGs, configuring data sources and resources. At the same time, for third-party systems, the api mode operation is provided. | Users on DolphinScheduler can achieve many-to-one or one-to-one mapping relationship through tenants and Hadoop users, which is very important for scheduling large data jobs. " | The scheduler uses distributed scheduling, and the overall scheduling capability will increase linearly with the scale of the cluster. Master and Worker support dynamic online and offline. 
Overload processing: Task queue mechanism, the number of schedulable tasks on a single machine can be flexibly configured, when too many tasks will be cached in the task queue, will not cause machine jam. | One-click deployment | Supports traditional shell tasks, and also support big data platform task scheduling: MR, Spark, SQL (mysql, postgresql, hive, sparksql), Python, Procedure, Sub_Process |  |




### System partial screenshot

![image](https://user-images.githubusercontent.com/48329107/61368744-1f5f3b00-a8c1-11e9-9cf1-10f8557a6b3b.png)

![image](https://user-images.githubusercontent.com/48329107/61368966-9dbbdd00-a8c1-11e9-8dcc-a9469d33583e.png)

![image](https://user-images.githubusercontent.com/48329107/61372146-f347b800-a8c8-11e9-8882-66e8934ada23.png)


### Document

- <a href="https://dolphinscheduler.apache.org/en-us/docs/user_doc/backend-deployment.html" target="_blank">Backend deployment documentation</a>

- <a href="https://dolphinscheduler.apache.org/en-us/docs/user_doc/frontend-deployment.html" target="_blank">Front-end deployment documentation</a>

- [**User manual**](https://dolphinscheduler.apache.org/en-us/docs/user_doc/system-manual.html?_blank "System manual") 

- [**Upgrade document**](https://dolphinscheduler.apache.org/en-us/docs/release/upgrade.html?_blank "Upgrade document") 

- <a href="http://106.75.43.194:8888" target="_blank">Online Demo</a> 

More documentation please refer to <a href="https://dolphinscheduler.apache.org/en-us/docs/user_doc/quick-start.html" target="_blank">[DolphinScheduler online documentation]</a>

### Recent R&D plan
Work plan of Dolphin Scheduler: [R&D plan](https://github.com/apache/incubator-dolphinscheduler/projects/1), Under the `In Develop` card is what is currently being developed, TODO card is to be done (including feature ideas)

### How to contribute code

Welcome to participate in contributing code, please refer to the process of submitting the code:
[[How to contribute code](https://github.com/apache/incubator-dolphinscheduler/issues/310)]

### Thanks

Dolphin Scheduler uses a lot of excellent open source projects, such as google guava, guice, grpc, netty, ali bonecp, quartz, and many open source projects of apache, etc.
It is because of the shoulders of these open source projects that the birth of the Dolphin Scheduler is possible. We are very grateful for all the open source software used! We also hope that we will not only be the beneficiaries of open source, but also be open source contributors. We also hope that partners who have the same passion and conviction for open source will join in and contribute to open source!

### Get Help
1. Submit an issue
1. Mail list: dev@dolphinscheduler.apache.org. Mail to dev-subscribe@dolphinscheduler.apache.org, follow the reply to subscribe the mail list.
1. Contact WeChat group manager, ID 510570367. This is for Mandarin(CN) discussion.

### License
Please refer to [LICENSE](https://github.com/apache/incubator-dolphinscheduler/blob/dev/LICENSE) file.
 
 







