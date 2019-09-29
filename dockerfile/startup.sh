#! /bin/bash

set -e

# 4g is too much for testing env on a single node
sed -i 's/-Xms4g/-Xms2g/g' /opt/escheduler/bin/escheduler-daemon.sh
#======================================================================
# code is still 1.1.0,but db commited. roll back
echo "1.1.0" > /opt/escheduler/sql/soft_version
rm -rf /opt/escheduler/sql/create/release-1.2.0_schema
rm -rf /opt/escheduler/sql/upgrade/1.2.0_schema
#======================================================================


if [ `netstat -anop|grep mysql|wc -l` -gt 0 ];then
    echo "MySQL is Running."
else
	MYSQL_ROOT_PWD="root@123"
        ESZ_DB="escheduler"
	echo "启动mysql服务"
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
	find /var/lib/mysql -type f -exec touch {} \; && service mysql restart $ sleep 10
	if [ ! -f /mysql_imported.log ];then
		echo "设置mysql密码"
		mysql --user=root --password=root -e "UPDATE mysql.user set authentication_string=password('$MYSQL_ROOT_PWD') where user='root'; FLUSH PRIVILEGES;"

		echo "设置mysql权限"
		mysql --user=root --password=$MYSQL_ROOT_PWD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
		echo "创建escheduler数据库"
		mysql --user=root --password=$MYSQL_ROOT_PWD -e "CREATE DATABASE IF NOT EXISTS \`$ESZ_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci; FLUSH PRIVILEGES;"
		echo "导入mysql数据"
		/opt/escheduler/script/create-escheduler.sh
		touch /mysql_imported.log
	fi

	if [ `mysql --user=root --password=$MYSQL_ROOT_PWD -s -r -e  "SELECT count(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA='escheduler';" | grep -v count` -eq 38 ];then
		echo "\`$ESZ_DB\` 表个数正确"
	else
		echo "\`$ESZ_DB\` 表个数不正确"
		mysql --user=root --password=$MYSQL_ROOT_PWD  -e "DROP DATABASE \`$ESZ_DB\`;"
		echo "创建escheduler数据库"
    mysql --user=root --password=$MYSQL_ROOT_PWD -e "CREATE DATABASE IF NOT EXISTS \`$ESZ_DB\` CHARACTER SET utf8 COLLATE utf8_general_ci; FLUSH PRIVILEGES;"
    echo "导入mysql数据"
    /opt/escheduler/script/create-escheduler.sh
    touch /mysql_imported.log
	fi
fi

/opt/zookeeper/bin/zkServer.sh restart 

# replace sleep 90 by nc
set +e
while true
do
    echo "waiting zk startup..."
    sleep 1s
    echo "ruok" | nc 127.0.0.1 2181
    if [ $? == 0 ] ; then
        break
    fi
done
set -e

echo "启动api-server"
/opt/escheduler/bin/escheduler-daemon.sh stop api-server
/opt/escheduler/bin/escheduler-daemon.sh start api-server

echo "启动master-server"
/opt/escheduler/bin/escheduler-daemon.sh stop master-server
python /opt/escheduler/script/del-zk-node.py 127.0.0.1 /escheduler/masters
/opt/escheduler/bin/escheduler-daemon.sh start master-server

echo "启动worker-server"
/opt/escheduler/bin/escheduler-daemon.sh stop worker-server
python /opt/escheduler/script/del-zk-node.py 127.0.0.1 /escheduler/workers
/opt/escheduler/bin/escheduler-daemon.sh start worker-server


echo "启动logger-server"
/opt/escheduler/bin/escheduler-daemon.sh stop logger-server
/opt/escheduler/bin/escheduler-daemon.sh start logger-server


echo "启动alert-server"
/opt/escheduler/bin/escheduler-daemon.sh stop alert-server
/opt/escheduler/bin/escheduler-daemon.sh start alert-server





echo "启动nginx"
/etc/init.d/nginx stop
nginx &
	

while true
do
 	sleep 101
done
exec "$@"
