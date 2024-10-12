#! /bin/sh

syslog_received="$(syslog-ng-ctl stats 2>/dev/null | grep 'center.*received' | rev | cut -d';' -f1 | rev)"

[ -z "${syslog_received}" ] && echo "No stats." && return 1

echo "Received messages: ${syslog_received}"
