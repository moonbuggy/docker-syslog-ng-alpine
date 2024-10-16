#!/usr/bin/with-contenv /bin/sh
#shellcheck shell=ash

CONFD='/etc/syslog-ng/conf.d'
TEMPLATES='/etc/syslog-ng/templates'

#log () { echo "[${0##*/}] $*"; }
log () { echo "syslog-ng-init: info: $*"; }

OPTIONS_CONF="${CONFD}/options.conf"
SQL_CONF="${CONFD}/d_sql.conf"
SYSLOG_CONF="${CONFD}/d_syslog.conf"

# fix the version in the config file
sed -E "s|^@version:.*|@version: $(echo ${SYSLOG_NG_VERSION} | cut -d'.' -f1,2)|" \
	-i /etc/syslog-ng/syslog-ng.conf

# configure stats frequency
[ -z ${STATS_FREQUENCY+set} ] && STATS_FREQUENCY='3600'
case ${SYSLOG_NG_VERSION:-4} in
	3*)	statsfreq_string="stats_freq(${STATS_FREQUENCY});"	;;
	*)	statsfreq_string="stats(freq(${STATS_FREQUENCY}));"	;;
esac

cp -f "${TEMPLATES}/options.template" "${OPTIONS_CONF}"
sed -i "${OPTIONS_CONF}" \
	-e "s/STATS_FREQ/${statsfreq_string}/"

log "Statistics frequency: ${STATS_FREQUENCY}"

# enable and configure the SQL destination if SQL_* environment variables are set
if env | grep -q SQL; then
	[ -z ${SQL_PORT+set} ] && SQL_PORT='3306'
	log "Logging to SQL ENABLED. (${SQL_HOST:-'none'}:${SQL_PORT})"

	cp -f "${TEMPLATES}/d_sql.template" "${SQL_CONF}"

	sed -i "${SQL_CONF}" \
		-e "s/SQL_HOST/${SQL_HOST}/" \
		-e "s/SQL_PORT/${SQL_PORT}/" \
		-e "s/SQL_USER/${SQL_USER}/" \
		-e "s/SQL_PASSWORD/${SQL_PASSWORD}/" \
		-e "s/SQL_DATABASE/${SQL_DATABASE}/"

# otherwise make sure the SQL destination is disabled
else
	log "Logging to SQL DISABLED."
  [ -f "${SQL_CONF}" ] && rm -f "${SQL_CONF}" >/dev/null 2>&1
fi

# enable and configure the syslog destination if SYSLOG_* environment variables are set
if env | grep -q SYSLOG | grep -qv SYSLOG_NG_VERSION; then
	[ -z ${SYSLOG_PORT+set} ] && SYSLOG_PORT='514'
	[ -z ${SYSLOG_FORMAT+set} ] && SYSLOG_FORMAT='RFC3164'
	[ -z ${SYSLOG_FORMAT+set} ] && SYSLOG_TRANSPORT='UDP'
	log "Logging to syslog ENABLED. (${SYSLOG_HOST:-'none'}:${SYSLOG_PORT}, ${SYSLOG_FORMAT} via ${SYSLOG_TRANSPORT})"

	cp -f "${TEMPLATES}/d_syslog.template" "${SYSLOG_CONF}"

	case ${SYSLOG_FORMAT} in
		*5424*) SYSLOG_DRIVER='syslog' ;;
		*) SYSLOG_DRIVER='network' ;;
	esac

	SYSLOG_TRANSPORT="$(echo "${SYSLOG_TRANSPORT}" | tr '[:upper:]' '[:lower:]')"
	case ${SYSLOG_TRANSPORT} in
		udp|tcp) ;;
		*) echo "Error. Invalid transport: ${SYSLOG_TRANSPORT}" ;;
	esac

	sed -i "${SYSLOG_CONF}" \
		-e "s/SYSLOG_HOST/${SYSLOG_HOST}/" \
		-e "s/SYSLOG_PORT/${SYSLOG_PORT}/" \
		-e "s/SYSLOG_DRIVER/${SYSLOG_DRIVER}/" \
		-e "s/SYSLOG_TRANSPORT/${SYSLOG_TRANSPORT}/"

# otherwise make sure the SQL destination is disabled
else
	log "Logging to syslog DISABLED."
  [ -f "${SYSLOG_CONF}" ] && rm -f "${SYSLOG_CONF}" >/dev/null 2>&1
fi


DO_ENABLE_LOCAL=false

if [ ! -z ${ENABLE_LOCAL+set} ]; then
	case "${ENABLE_LOCAL}" in
		true|True|TRUE|yes|Yes|YES|1|on|On|ON)
			DO_ENABLE_LOCAL=true
			;;
	esac
fi

# enable the local destination if the appropriate environment variable is set
if ${DO_ENABLE_LOCAL}; then
	log "Logging to /var/log/messages ENABLED."
	cp -f "${TEMPLATES}/d_local.template" "${CONFD}/d_local.conf"
else # otherwise make sure it's disabled
	log "Logging to /var/log/messages DISABLED."
	rm -f "${CONFD}/d_local.conf" >/dev/null 2>&1
fi
