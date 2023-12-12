#!/bin/sh

set -e

# TODO delete this block
set -x
find /opt -exec ls -ld \{\} +

/opt/bootstrap/bootstrap.sh

runas() {
  su "$1" -s /bin/sh -c "$2"
}

log() {
  local ctx="$2"
  #"$@" &>/var/log/$ctx.log
  "$@" 2>&1 | awk '$0="['"$ctx"'] "$0'
  #nl -s "[$ctx] "
  #sed "s/^/[$ctx] /"
}

log runas munin /opt/updater/updater.sh &
log runas httpd /opt/server/server.sh &

wait
