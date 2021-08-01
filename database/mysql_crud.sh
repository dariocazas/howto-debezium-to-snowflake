#!/bin/bash
DOCKER_COMPOSE_FILE=docker-compose.yml
DOCKER_COMPOSE_RELATIVE_PATH=../docker

run_sql() {
    echo "$1"
    echo "$1" | docker-compose \
        -f $DOCKER_COMPOSE_FILE \
        exec -T mysql \
        bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory 2> /dev/null'
}

DML=`cat sql/01_mysql_changes.sql`

cd $DOCKER_COMPOSE_RELATIVE_PATH
run_sql "$DML"
