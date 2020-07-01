#!/bin/bash

if  [ ! -d /data/database ]; then
	echo "Creating Database folder..."
	mkdir -p /data/database
	chown postgres:postgres -R /data/database
	su -c "/usr/lib/postgresql/12/bin/initdb --pgdata=/data/database" postgres
fi

chown postgres:postgres -R /data/database

echo "Starting PostgreSQL..."
su -c "/usr/lib/postgresql/12/bin/pg_ctl --timeout=600 --wait --pgdata=/data/database start" postgres

if [ ! -f "/data/firstrun" ]; then
	echo "Creating Greenbone Vulnerability Manager database"
	su -c "createuser -DRS gvm" postgres
	su -c "createdb -O gvm gvmd" postgres
	su -c "psql --dbname=gvmd --command='create role dba with superuser noinherit;'" postgres
	su -c "psql --dbname=gvmd --command='grant dba to gvm;'" postgres
	su -c "psql --dbname=gvmd --command='create extension \"uuid-ossp\";'" postgres
	touch /data/firstrun
fi

function stop-postgresql()
{
    su -c "/usr/lib/postgresql/12/bin/pg_ctl --wait --pgdata=/data/database stop" postgres
}

trap stop-postgresql EXIT

tail -f /var/log/postgresql/*
