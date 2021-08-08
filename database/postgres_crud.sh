#!/bin/bash
DOCKER_COMPOSE_FILE=docker-compose.yml
DOCKER_COMPOSE_RELATIVE_PATH=../services

run_sql() {
    echo "$1"
    echo "$1" | docker-compose \
        -f docker-compose.yml \
        exec -T postgres \
        env PGOPTIONS="--search_path=inventory" \
        bash -c 'psql -U $POSTGRES_USER postgres 2> /dev/null'
}

DML=`cat sql/01_postgres_changes.sql`

cd $DOCKER_COMPOSE_RELATIVE_PATH
run_sql "$DML"
