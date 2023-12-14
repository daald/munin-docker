#!/bin/sh

set -e

/opt/bootstrap/genconfig.sh

set +e

chown munin /var/lib/munin/

mkdir -p /var/lib/munin/cgi-tmp/
chown httpd -R /var/lib/munin/cgi-tmp/

touch /var/log/munin/munin-graph.log
chown httpd.munin /var/log/munin/munin-graph.log /var/lib/munin/limits
chmod ug+rw /var/log/munin/munin-graph.log /var/lib/munin/limits
