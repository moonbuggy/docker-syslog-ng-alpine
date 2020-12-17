FROM moonbuggy2000/alpine-s6:3.12.3

RUN apk add --no-cache \
		libdbi-drivers \
		syslog-ng-http \
		syslog-ng-json \
		syslog-ng-scl \
		syslog-ng syslog-ng-sql \
		syslog-ng-tags-parser

COPY /etc/ /etc/

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

ENTRYPOINT ["/init"]
