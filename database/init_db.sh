#!/bin/bash
DOCKER_COMPOSE_FILE=docker-compose.yml
DOCKER_COMPOSE_RELATIVE_PATH=../services

MYSQL=`cat sql/00_mysql_init.sql`
POSTGRES=`cat sql/00_postgres_init.sql`

cd $DOCKER_COMPOSE_RELATIVE_PATH

echo "MySQL new table"
echo "$MYSQL"
echo "$MYSQL" | docker-compose \
    -f $DOCKER_COMPOSE_FILE \
    exec -T mysql \
    bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory'

echo "PostgreSQL new table"
echo "$POSTGRES"
echo "$POSTGRES" | docker-compose \
    -f docker-compose.yml \
    exec -T postgres \
    env PGOPTIONS="--search_path=inventory" \
    bash -c 'psql -U $POSTGRES_USER postgres'
