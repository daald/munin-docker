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

touch /var/log/munin/munin-cgi-html.log && chown httpd /var/log/munin/munin-cgi-html.log
touch /var/log/munin/munin-cgi-graph.log && chown httpd /var/log/munin/munin-cgi-graph.log

log runas munin /opt/updater/updater.sh &
log runas httpd /opt/server/server.sh &

#sleep 10  # spawn doesn't come up before update was done. why???
#spawn-fcgi -s /var/run/munin/fastcgi-graph.sock -U httpd -u munin -g munin -- /usr/share/webapps/munin/cgi/munin-cgi-graph
#spawn-fcgi -s /var/run/munin/fastcgi-html.sock  -U httpd -u munin -g munin -- /usr/share/webapps/munin/cgi/munin-cgi-html

wait
