FROM alpine:3.10

RUN apk add --no-cache syslog-ng syslog-ng-sql syslog-ng-scl syslog-ng-http syslog-ng-json syslog-ng-tags-parser libdbi-drivers

RUN mkdir /etc/syslog-ng/templates

COPY config/syslog-ng.conf /etc/syslog-ng/
COPY config/d_local.conf /etc/syslog-ng/templates/d_local.template
COPY config/d_sql.conf /etc/syslog-ng/templates/d_sql.template
COPY config/options.conf /etc/syslog-ng/conf.d/

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh; \
    ln -s /usr/local/bin/docker-entrypoint.sh .

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/syslog-ng", "-F"]
