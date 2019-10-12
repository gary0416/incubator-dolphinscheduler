#!/bin/bash

# will not be necessary in new version
function tempFix() {
  # compatible 1.1.0 and before
  if [ ! -f /opt/escheduler/script/del-zk-node.py ]; then
    mv /opt/escheduler/script/del_zk_node.py /opt/escheduler/script/del-zk-node.py
  fi
}

function checkZK() {
  while true; do
    echo "waiting for ZooKeeper..."
    sleep 1s

    if echo "ruok" | nc "$ZK_HOST" "$ZK_PORT"; then
      echo -e "\nZooKeeper has already started"
      break
    fi
  done
}

if [ "$1" = "help" ]; then
  echo "Usage: $(basename "$0") (master|worker|alert|help|debug)"
  exit 0
elif [ "$1" = "debug" ]; then
  # debuging
  echo "sleep 1d..."
  sleep 1d
  exit 0
fi

if [ "$1" = "master" ]; then
  echo "Starting master-server"
  LOG_FILE="-Dspring.config.location=conf/application_master.properties -Ddruid.mysql.usePingMethod=false"
  CLASS=cn.escheduler.server.master.MasterServer

  checkZK
elif [ "$1" = "worker" ]; then
  echo "Starting worker-server and logger-server"
  LOG_FILE="-Dspring.config.location=conf/application_worker.properties -Ddruid.mysql.usePingMethod=false"
  CLASS=cn.escheduler.server.worker.WorkerServer

  checkZK
  HOST_IP=$(ip -o -4 addr show up primary scope global | grep -v docker | grep -v br- | head -1 | awk '{print $4}' | cut -d"/" -f 1)
  python /opt/escheduler/script/del-zk-node.py $HOST_IP /escheduler/workers

  echo "Starting logger-server"
  # 4g is too much for init
  sed -i 's/-Xms4g/-Xms1g/g' /opt/escheduler/bin/escheduler-daemon.sh
  /opt/escheduler/bin/escheduler-daemon.sh start logger-server

  # support extra init script
  WORKER_EXTRA_INIT_SCRIPT=/opt/escheduler/script/worker-extra-init.sh
  if [ -f $WORKER_EXTRA_INIT_SCRIPT ]; then
    echo "Running worker extra init script"
    chmod +x $WORKER_EXTRA_INIT_SCRIPT
    $WORKER_EXTRA_INIT_SCRIPT
  fi

  echo "Starting worker-server"
elif [ "$1" = "alert" ]; then
  if [ -n "$ALERT_SERVER_STARTUP_DELAY" ]; then
    echo "delay $ALERT_SERVER_STARTUP_DELAY seconds before starting(waiting for master and worker)"
    sleep "$ALERT_SERVER_STARTUP_DELAY"
  fi
  echo "Starting alert-server"
  LOG_FILE="-Dspring.config.location=conf/application_alert.properties -Ddruid.mysql.usePingMethod=false"
  CLASS=cn.escheduler.alert.AlertServer
fi

tempFix

export ESCHEDULER_HOME=/opt/escheduler
export ESCHEDULER_CONF_DIR=$ESCHEDULER_HOME/conf
export ESCHEDULER_LIB_JARS="$ESCHEDULER_HOME/lib/*"
export ESCHEDULER_OPTS="-server -Xmx16g -Xms1g -Xss512k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70"
cd $ESCHEDULER_HOME || exit 1
exec $JAVA_HOME/bin/java $LOG_FILE $ESCHEDULER_OPTS -classpath $ESCHEDULER_CONF_DIR:$ESCHEDULER_LIB_JARS $CLASS
