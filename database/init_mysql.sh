#!/bin/bash
DATA_DB_FILE=data_mysql.csv
DOCKER_COMPOSE_FILE=docker-compose-debezium.yml
DOCKER_COMPOSE_RELATIVE_PATH=../docker

run_sql() {
    echo "$1"
    echo "$1" | docker-compose \
        -f $DOCKER_COMPOSE_FILE \
        exec -T mysql \
        bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory'
}

read -d '' DDL << EOF
CREATE TABLE pet (
    id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20), 
    owner VARCHAR(20),
    species VARCHAR(20), 
    sex CHAR(1), 
    birth DATE, 
    death DATE);
EOF

javac RandomGenerator.java
rm $DATA_DB_FILE
java -cp . RandomGenerator ',' female name dog F null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name cat M null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name fish F null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name bird M null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name horse M null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name dog M null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name cat F null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name fish M null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name bird F null null >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name horse M null null >> $DATA_DB_FILE

DML="INSERT INTO pet(name, owner, species, sex, birth, death) VALUES "
while read row; do
    DML="$DML ( $row ),"
done <$DATA_DB_FILE
DML=${DML%,}

cd $DOCKER_COMPOSE_RELATIVE_PATH

echo "###  MySQL PET table: INIT ###"
run_sql "$DDL"
run_sql "$DML"

echo "###  MySQL PET table: SAMPLE QUERY ###"
run_sql "SELECT * from pet limit 5;"
run_sql "SELECT count(*) AS number_of_pets from pet;"