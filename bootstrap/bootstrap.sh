#!/bin/sh

set -e

/opt/bootstrap/genconfig.sh

cat /etc/passwd
chown munin /var/lib/munin/
