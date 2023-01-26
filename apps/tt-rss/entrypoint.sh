#!/usr/bin/env bash

#shellcheck disable=SC1091
source "/shim/umask.sh"
source "/shim/vpn.sh"

set -euo pipefail

export PGPASSWORD=${TTRSS_DB_PASS:-password}
T_DB_HOST=${TTRSS_DB_HOST:-t-db-1}
T_DB_USER=${TTRSS_DB_USER:-postgres}
T_DB_NAME=${TTRSS_DB_NAME:-postgres}

while ! pg_isready -h ${T_DB_HOST} -U ${T_DB_USER}; do
	echo "waiting until '${T_DB_HOST}' is ready..."
	sleep 3
done


# Create schema if not already set
PSQL="psql -q -h ${T_DB_HOST} -U ${T_DB_USER} ${T_DB_NAME}"
$PSQL -c "create extension if not exists pg_trgm"

if ! $PSQL -c 'select * from ttrss_version'; then
	$PSQL < /app/schema/ttrss_schema_pgsql.sql
fi

# PHP in debug mode
if [ ! -z "${TTRSS_XDEBUG_ENABLED:-}" ]; then
	if [ -z "${TTRSS_XDEBUG_HOST:-}" ]; then
		export TTRSS_XDEBUG_HOST=$(ip ro sh 0/0 | cut -d " " -f 3)
	fi
	echo enabling xdebug with the following parameters:
	env | grep TTRSS_XDEBUG
	cat > /etc/php/7.4/conf.d/50_xdebug.ini <<EOF
zend_extension=xdebug.so
xdebug.mode=develop,trace,debug
xdebug.start_with_request = yes
xdebug.client_port = ${TTRSS_XDEBUG_PORT}
xdebug.client_host = ${TTRSS_XDEBUG_HOST}
EOF
fi

php /app/update.php --update-schema=force-yes

touch /tmp/.app_is_ready

#Start web server with php support
/usr/sbin/php-fpm81
/usr/sbin/nginx -c /etc/nginx/nginx.conf -p /var/lib/nginx ${EXTRA_ARGS:-}

exec php /app/update_daemon2.php
