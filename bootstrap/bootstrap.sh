#!/bin/sh

set -e

/opt/bootstrap/genconfig.sh

cat /etc/passwd
chown munin /var/lib/munin/

mkdir /a
chown httpd /a
chmod a+rwX /a

chown httpd -R /var/lib/munin/cgi-tmp/

touch /var/log/munin/munin-graph.log
chown httpd.munin /var/log/munin/munin-graph.log
chmod ug+rw /var/log/munin/munin-graph.log
