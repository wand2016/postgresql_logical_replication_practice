#!/bin/bash

cd /var/lib/postgresql/data

createdb testdb
psql -l

# create table and its publication
psql testdb -c 'CREATE TABLE testtbl(i int primary key, j int)'
psql testdb -c 'CREATE PUBLICATION mypub FOR TABLE testtbl'


# configure logical replication
psql <<EOF
ALTER SYSTEM SET wal_level = 'logical';
ALTER SYSTEM SET max_replication_slots = 2;
ALTER SYSTEM SET max_wal_senders = 2;
EOF

cat postgresql.auto.conf

# host-based authentication of replication standby servers
cat >> pg_hba.conf << EOF
host    testdb     postgres 0.0.0.0/0     trust
EOF

# ensure that hba settings are applied
psql -P pager -c 'SELECT * FROM pg_hba_file_rules'


pg_ctl restart
