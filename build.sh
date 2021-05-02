#! /bin/bash

#NOOP='true'
#DO_PUSH='true'
#NO_BUILD='true'

DOCKER_REPO="${DOCKER_REPO:-moonbuggy2000/syslog-ng-alpine}"

all_tags='3.27 3.30'
default_tag='latest'

. "hooks/.build.sh"
