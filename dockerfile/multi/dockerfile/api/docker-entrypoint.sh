#!/bin/bash

# will not be necessary in new version
function tempFix() {
  # code is still 1.1.0,but db commited. roll back
  echo "1.1.0" >/opt/escheduler/sql/soft_version
  rm -rf /opt/escheduler/sql/create/release-1.2.0_schema
  rm -rf /opt/escheduler/sql/upgrade/1.2.0_schema

  # compatible 1.1.0 and before
  if [ ! -f /opt/escheduler/script/create-escheduler.sh ]; then
    mv /opt/escheduler/script/create_escheduler.sh /opt/escheduler/script/create-escheduler.sh
  fi
}

function checkMySQL() {
  while true; do
    echo "waiting for MySQL..."
    sleep 1s

    if mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" --user=root --password="$MYSQL_ROOT_PWD" -e "select 1;"; then
      echo -e "\nMySQL has already started"
      break
    fi
  done
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
  echo "Usage: $(basename "$0") (api|help|debug)"
  exit 0
elif [ "$1" = "api" ]; then
  echo "Starting api-server"
  LOG_FILE="-Dlogging.config=conf/apiserver_logback.xml"
  CLASS=cn.escheduler.api.ApiApplicationServer

  tempFix

  set +e
  checkMySQL
  checkZK
  set -e

  if [ $(mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" --user=root --password="$MYSQL_ROOT_PWD" -s -r -e "SELECT count(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA='escheduler';" | grep -v count) -eq 38 ]; then
    echo "\`$ESZ_DB\` table num correct"
  else
    echo "\`$ESZ_DB\` table num incorrect"
    mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" --user=root --password="$MYSQL_ROOT_PWD" -e "DROP DATABASE \`$ESZ_DB\`;"
    echo "creating escheduler db"
    mysql --host="$MYSQL_HOST" --port="$MYSQL_PORT" --user=root --password="$MYSQL_ROOT_PWD" -e "CREATE DATABASE IF NOT EXISTS \`$ESZ_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci; FLUSH PRIVILEGES;"
    echo "importing mysql data"
    /opt/escheduler/script/create-escheduler.sh
  fi
elif [ "$1" = "debug" ]; then
  # debuging
  echo "sleep 1d..."
  sleep 1d
  exit 0
fi

export ESCHEDULER_HOME=/opt/escheduler
export ESCHEDULER_CONF_DIR=$ESCHEDULER_HOME/conf
export ESCHEDULER_LIB_JARS="$ESCHEDULER_HOME/lib/*"
export ESCHEDULER_OPTS="-server -Xmx16g -Xms1g -Xss512k -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70"
cd $ESCHEDULER_HOME || exit 1
exec $JAVA_HOME/bin/java $LOG_FILE $ESCHEDULER_OPTS -classpath $ESCHEDULER_CONF_DIR:$ESCHEDULER_LIB_JARS $CLASS
