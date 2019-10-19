#! /bin/sh

CONFD=/etc/syslog-ng/conf.d
TEMPLATES=/etc/syslog-ng/templates

# enable and configure the SQL destination if SQL_* environment variables are set
if $(env | grep -q SQL); then

	if [ -z ${SQL_PORT} ]; then
		export SQL_PORT=3306
	fi

	cp -f $TEMPLATES/d_sql.template $CONFD/d_sql.conf

	sed -i "s/SQL_HOST/${SQL_HOST}/" $CONFD/d_sql.conf
	sed -i "s/SQL_PORT/${SQL_PORT}/" $CONFD/d_sql.conf
	sed -i "s/SQL_USER/${SQL_USER}/" $CONFD/d_sql.conf
	sed -i "s/SQL_PASSWORD/${SQL_PASSWORD}/" $CONFD/d_sql.conf
	sed -i "s/SQL_DATABASE/${SQL_DATABASE}/" $CONFD/d_sql.conf

# otherwise make sure the SQL destination is disabled
elif [ -f $CONFD/d_sql.conf ]; then

	rm -f $CONFD/d_sql.conf

fi

# disable the local destination if the appropriate environment variable is set
if $(env| grep -q DISABLE_LOCAL); then

	rm -f $CONFD/d_local.conf

# otherwise make sure it's enabled
elif [ ! -f $CONFD/d_local.conf ]; then

	cp $TEMPLATES/d_local.template $CONFD/d_local.conf

fi

exec "$@"
