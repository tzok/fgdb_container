# OS
FROM mysql:5.7

# Maintainer
MAINTAINER Riccardo Bruno <riccardo.bruno@ct.infn.it>

# Environment
ENV FG_USER=futuregateway \
    FG_DIR=/home/futuregateway \
    MYSQL_ROOT_PASSWORD=rpass \
    MYSQL_USER=fgapiserver \
    MYSQL_PASSWORD=fgapiserver_password \
    MYSQL_DATABASE=fgapiserver \
    FGDB_GIT=https://github.com/indigo-dc/fgAPIServer.git \
    FGDB_BRANCH=safe_transaction

# User and working directory
WORKDIR $FG_DIR

# Package Installation and TeSS cloning
RUN adduser --disabled-password --gecos "" $FG_USER &&\
    chown -R $FG_USER:$FG_USERS $FG_DIR &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends ca-certificates\
    sudo git mlocate vim &&\
    sudo echo "$FG_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# User and working directory
USER $FG_USER
WORKDIR $FG_DIR

# Getting FG repo
RUN git clone $FGDB_GIT -b $FGDB_BRANCH

#
# Additional setup for Executor Interfaces
#

# Grid and Cloud Engine UsersTracking database
ENV UTDB_HOST=fgdb \
    UTDB_PORT=3306 \
    UTDB_USER=tracking_user \
    UTDB_PASSWORD=userstracking \
    UTDB_DATABASE=userstracking \
    GNCENG=https://github.com/csgf/grid-and-cloud-engine.git \
    GNCENG_BRANCH=FutureGateway
RUN git clone $GNCENG -b $GNCENG_BRANCH

# Working directory
USER root
#RUN sed -i "s/#bind-address\t=\ 127.0.0.1/bind-address     =\ 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf
RUN cat $FG_DIR/fgAPIServer/fgapiserver_db.sql > /docker-entrypoint-initdb.d/dbsetup.sql
RUN cat $FG_DIR/grid-and-cloud-engine/UsersTrackingDB/UsersTrackingDB.sql >> /docker-entrypoint-initdb.d/dbsetup.sql

# mySQL port 3306 available to the world outside this container
EXPOSE 3306

