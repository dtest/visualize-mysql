FROM mysql:5.7

ADD world_innodb.sql /docker-entrypoint-initdb.d/world.sql

EXPOSE 3306
CMD ["mysqld"]
