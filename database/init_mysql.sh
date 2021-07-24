#!/bin/bash
DATA_DB_FILE=data_mysql.csv
DOCKER_COMPOSE_FILE=docker-compose-debezium.yml
DOCKER_COMPOSE_RELATIVE_PATH=../docker

run_sql() {
    echo "$1"
    echo "$1" | docker-compose \
        -f $DOCKER_COMPOSE_FILE \
        exec -T mysql \
        bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory 2> /dev/null'
}

read -d '' DDL << EOF
CREATE TABLE pet (
    id MEDIUMINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20), 
    owner VARCHAR(20),
    species VARCHAR(20), 
    sex CHAR(1)
)
EOF

javac RandomGenerator.java
rm $DATA_DB_FILE
java -cp . RandomGenerator ',' female name dog F >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name cat M >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name fish F >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name bird M >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name horse M >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name dog M >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name cat F >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name fish M >> $DATA_DB_FILE
java -cp . RandomGenerator ',' female name bird F >> $DATA_DB_FILE
java -cp . RandomGenerator ',' male name horse M >> $DATA_DB_FILE

DML="INSERT INTO pet(name, owner, species, sex) VALUES "
while read row; do
    DML="$DML ( $row ),"
done <$DATA_DB_FILE
DML=${DML%,}

cd $DOCKER_COMPOSE_RELATIVE_PATH

echo "###  MySQL PET table: INIT ###"
echo
run_sql "$DDL"
echo
run_sql "$DML"
echo

echo "###  MySQL PET table: SAMPLE QUERY ###"
echo
run_sql "SELECT * from pet limit 5"
echo
run_sql "SELECT count(*) AS number_of_pets from pet;"
echo 
run_sql "UPDATE pet set name=LEFT(UUID(), 8) order by id desc limit 2"
echo
run_sql "DELETE FROM pet order by id desc limit 1"
echo
run_sql "SELECT count(*) AS number_of_pets from pet"
echo 