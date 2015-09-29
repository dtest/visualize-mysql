#!/bin/bash

TESTTYPE=$1

OLTP_ROWS=200000
OLTP_SECONDS=60
OUTDIR=/var/log/sysbench

if [ ! -d $OUTDIR ]; then
  mkdir -p $OUTDIR
fi

function timestamp {
  echo "$(date +%Y-%m-%d_%H_%M_%S)"
}

function setup_oltp_database {
  echo "setting up sysbench database"
  mysqladmin -h mysql -uroot -p$MYSQL_ROOT_PASSWORD -f drop sbtest
  mysqladmin -h mysql -uroot -p$MYSQL_ROOT_PASSWORD create sbtest
}

function run_oltp_test {
  OUTFILE=$OUTDIR/`timestamp`.sysbench.oltp.rows.$OLTP_ROWS.seconds.$OLTP_SECONDS.log

  for NUM_THREADS in 1 2 4 8 16 32;
    do
    setup_oltp_database
    sysbench --test=oltp --db-driver=mysql --oltp-table-size=$OLTP_ROWS --max-requests=0 --mysql-table-engine=InnoDB \
      --mysql-host=mysql --mysql-user=root --mysql-password=$MYSQL_ROOT_PASSWORD --mysql-engine-trx=yes --num-threads=1 prepare

    sleep 5

    sysbench --test=oltp --db-driver=mysql --oltp-table-size=$OLTP_ROWS --max-time=$OLTP_SECONDS --max-requests=0 \
      --mysql-table-engine=InnoDB --mysql-host=mysql --mysql-user=root --mysql-password=$MYSQL_ROOT_PASSWORD \
      --mysql-engine-trx=yes --num-threads=$NUM_THREADS run >> $OUTFILE
  done
}

if [ "$TESTTYPE" = oltp ]; then
  echo "`timestamp` running sysbench $TESTTYPE test with $OLTP_ROWS rows for $OLTP_SECONDS seconds"
  setup_oltp_database
  run_oltp_test
fi