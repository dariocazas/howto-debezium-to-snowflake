#!/bin/bash
DATA_DB_FILE=data_postgres.csv
DOCKER_COMPOSE_FILE=docker-compose-debezium.yml
DOCKER_COMPOSE_RELATIVE_PATH=../docker

run_sql() {
    echo "$1"
    echo "$1" | docker-compose \
        -f docker-compose-debezium.yml \
        exec -T postgres \
        env PGOPTIONS="--search_path=inventory" \
        bash -c 'psql -U $POSTGRES_USER postgres'
}

read -d '' DDL << EOF
CREATE TABLE accounts (
    user_id serial PRIMARY KEY,
    username VARCHAR ( 50 ) UNIQUE NOT NULL,
    password VARCHAR ( 50 ) NOT NULL,
    email VARCHAR ( 255 ) UNIQUE NOT NULL,
    created_on TIMESTAMP NOT NULL DEFAULT NOW(),
    last_login TIMESTAMP 
);
EOF

javac RandomGenerator.java
rm $DATA_DB_FILE
for i in {1..10}; do
    java -cp . RandomGenerator ',' username country email null >> $DATA_DB_FILE
done

DML="INSERT INTO accounts(username, password, email, last_login) VALUES "
while read row; do
    DML="$DML ( $row ),"
done <$DATA_DB_FILE
DML=${DML%,}


cd $DOCKER_COMPOSE_RELATIVE_PATH

echo "###  Postgres ACCOUNTS table: INIT ###"
run_sql "$DDL"
run_sql "$DML"

echo "###  Postgres ACCOUNTS table: SAMPLE QUERY ###"
run_sql "SELECT * from accounts limit 5;"
run_sql "SELECT count(*) AS number_of_accounts from accounts;"