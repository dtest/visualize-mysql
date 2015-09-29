#!/bin/bash
docker-env ple15

echo "Creating sysbench database"
docker exec -it mysql mysql -hmysql -uroot -pple15 -e "DROP DATABASE IF EXISTS sbtest; CREATE DATABASE sbtest;"

echo "Preparing sysbench"
docker exec -it sysbench sysbench --test=oltp --db-driver=mysql --oltp-table-size=1000000 --max-requests=0 --mysql-table-engine=InnoDB \
 --mysql-host=mysql --mysql-user=root --mysql-password=ple15 --mysql-db=sbtest --mysql-engine-trx=yes --num-threads=1 prepare

echo "Running sysbench for 60 seconds with '$1' threads"
docker exec -it sysbench sysbench --test=oltp --db-driver=mysql --oltp-table-size=1000000 --max-requests=0 --mysql-table-engine=InnoDB \
  --mysql-host=mysql --mysql-user=root --mysql-password=ple15 --mysql-db=sbtest --mysql-engine-trx=yes --max-time=60 --num-threads=$1 run > sysbench.$1.out