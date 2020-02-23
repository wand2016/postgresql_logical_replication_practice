#!/bin/bash

cd /var/lib/postgresql/data

createdb testdb
psql -l

psql testdb -c 'CREATE TABLE testtbl(i int primary key, j int)'
psql testdb -c "CREATE SUBSCRIPTION mysub CONNECTION 'dbname=testdb host=pub' PUBLICATION mypub";

psql <<EOF
ALTER SYSTEM SET max_replication_slots = 1;
ALTER SYSTEM SET max_sync_workers_per_subscription = 1;
ALTER SYSTEM SET max_logical_replication_workers = 2;
ALTER SYSTEM SET max_worker_processes = 3;
EOF

cat postgresql.auto.conf


# ensure that hba settings are applied
psql -P pager -c 'SELECT * FROM pg_hba_file_rules'


pg_ctl restart
