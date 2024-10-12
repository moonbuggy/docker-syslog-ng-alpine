#! /bin/bash
# shellcheck disable=SC2034

DOCKER_REPO="${DOCKER_REPO:-moonbuggy2000/syslog-ng-alpine}"

# all_tags='latest'
default_tag='latest'

TARGET_VERSION_TYPE='minor'

custom_source_versions () {
  local alpine_latest
  alpine_latest="$(echo "${@}" | xargs -n1 | grep -oE '^[0-9]+\.[0-9]+' | sort -uV | tail -n1)"
  echo "$(alpine_package_version syslog-ng ${alpine_latest})"
}

. "hooks/.build.sh"
