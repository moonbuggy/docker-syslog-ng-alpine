ARG ALPINE_VERSION="3.13"
ARG FROM_IMAGE="moonbuggy2000/alpine-s6:${ALPINE_VERSION}"

ARG TARGET_ARCH_TAG="amd64"

## build the image
#
FROM "${FROM_IMAGE}" AS builder

# QEMU static binaries from pre_build
ARG QEMU_DIR
ARG QEMU_ARCH=""
COPY _dummyfile "${QEMU_DIR}/qemu-${QEMU_ARCH}-static*" /usr/bin/

ARG SYSLOG_NG_VERSION="3.30"
RUN apk add --no-cache \
		libdbi-drivers \
		syslog-ng=~${SYSLOG_NG_VERSION} \
		syslog-ng-http \
		syslog-ng-json \
		syslog-ng-scl \
		syslog-ng-sql \
		syslog-ng-tags-parser

COPY ./etc/ /etc/
COPY ./healthcheck.sh /

RUN rm -f _dummyfile "/usr/bin/qemu-${QEMU_ARCH}-static" >/dev/null 2>&1


## drop the QEMU binaries
#
FROM "moonbuggy2000/scratch:${TARGET_ARCH_TAG}"

COPY --from=builder / /

EXPOSE 514/udp
EXPOSE 601/tcp
EXPOSE 6514/tcp

ENTRYPOINT ["/init"]

HEALTHCHECK --start-period=30s --timeout=10s CMD /healthcheck.sh
