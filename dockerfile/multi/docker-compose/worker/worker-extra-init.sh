#!/bin/bash

# DolphinScheduler won't automatically create non-exists tenant user and dir currently. Shell job will be faild.
useradd gary && mkdir -p /opt/test/gary && chown gary /opt/test/gary

# support spark,mount hdp spark-client dir with ro mode
# to prevent changing JAVA_HOME var in spark-env.sh,manually setting env.
# load-spark-env.sh need SPARK_ENV_LOADED
# .escheduler_env.sh content:
#export HADOOP_HOME=${HADOOP_HOME:-/usr/hdp/2.6.3.0-235/hadoop}
#export HADOOP_CONF_DIR=/opt/escheduler/conf
#export SPARK_HOME1=/opt/soft/spark1
#export SPARK_HOME2=/opt/spark2-client
#export PYTHON_HOME=/opt/soft/python
#export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#export HIVE_HOME=/opt/soft/hive
#export FLINK_HOME=/opt/soft/flink
#export PATH=$HADOOP_HOME/bin:$SPARK_HOME1/bin:$SPARK_HOME2/bin:$PYTHON_HOME:$JAVA_HOME/bin:$HIVE_HOME/bin:$PATH:$FLINK_HOME/bin:$PATH
## new:
#export HDP_VERSION=2.6.3.0-235
#export SPARK_CONF_DIR=${SPARK_HOME}/conf
#export SPARK_ENV_LOADED=1
#export SPARK_LOG_DIR=/var/log/spark2
#export SPARK_PID_DIR=/var/run/spark2
#export SPARK_DAEMON_MEMORY=1024m
#export SPARK_IDENT_STRING=$USER
#export SPARK_NICENESS=0
ln -fs /opt/spark2-client/bin/spark-submit /usr/bin/spark-submit && mkdir -p /usr/hdp/2.6.3.0-235/hadoop/lib
