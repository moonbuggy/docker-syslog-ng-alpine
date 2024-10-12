ARG ALPINE_VERSION="3.17"
ARG FROM_IMAGE="moonbuggy2000/alpine-s6:${ALPINE_VERSION}"

## build the image
#
FROM "${FROM_IMAGE}"

ARG APK_PROXY=""
ARG SYSLOG_NG_VERSION="3.38"
RUN if [ ! -z "${APK_PROXY}" ]; then \
    alpine_minor_ver="$(grep -o 'VERSION_ID.*' /etc/os-release | grep -oE '([0-9]+\.[0-9]+)')"; \
    mv /etc/apk/repositories /etc/apk/repositories.bak; \
    echo "${APK_PROXY}/alpine/v${alpine_minor_ver}/main" >/etc/apk/repositories; \
    echo "${APK_PROXY}/alpine/v${alpine_minor_ver}/community" >>/etc/apk/repositories; \
	fi \
	&& apk add --no-cache \
		libdbi-drivers \
		syslog-ng=~${SYSLOG_NG_VERSION} \
		syslog-ng-http \
		syslog-ng-json \
		syslog-ng-scl \
		syslog-ng-sql \
		syslog-ng-tags-parser \
	&& (mv -f /etc/apk/repositories.bak /etc/apk/repositories >/dev/null 2>&1 || true) \
	&& add-contenv "SYSLOG_NG_VERSION=${SYSLOG_NG_VERSION}"

COPY ./root/ /

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

ENTRYPOINT ["/init"]

HEALTHCHECK --start-period=30s --timeout=10s CMD /healthcheck.sh
