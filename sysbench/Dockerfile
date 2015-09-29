FROM debian:wheezy
MAINTAINER Derek Downey downey@pythian.com

RUN apt-get update && apt-get install -y mysql-client sysbench && rm -rf /var/lib/apt/lists/*

## gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
#RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

#ENV MYSQL_MAJOR 5.7
#ENV MYSQL_VERSION 5.7.8-rc

#RUN echo "deb http://repo.mysql.com/apt/ubuntu/ precise mysql-${MYSQL_MAJOR}-dmr" > /etc/apt/sources.list.d/mysql.list
#RUN yum install -y
#RUN git clone --depth=1 https://github.com/akopytov/sysbench
#WORKDIR /sysbench
#RUN ./autogen.sh
#RUN ./configure
#RUN make
#RUN make install
#RUN mkdir -p /usr/share/doc/sysbench/tests/
#RUN rsync -a sysbench/tests/db  /usr/share/doc/sysbench/tests/

ADD entrypoint.sh /etc/entrypoint.sh
ADD run_sysbench.sh /run_sysbench.sh
RUN chown root:root /etc/entrypoint.sh && chmod 700 /etc/entrypoint.sh

ENTRYPOINT ["/etc/entrypoint.sh"]

CMD ["-d"]

#RUN yum install -y git automake gcc make g++ libtool autoconf gettext pkgconfig mysql-client mysql-common rsync
#RUN git clone --depth=1 https://github.com/akopytov/sysbench
#WORKDIR /sysbench
#RUN ./autogen.sh
#RUN ./configure
#RUN make
#RUN make install
#RUN mkdir -p /usr/share/doc/sysbench/tests/
#RUN rsync -a sysbench/tests/db  /usr/share/doc/sysbench/tests/