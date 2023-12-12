#!/bin/sh

set -e

/opt/bootstrap/genconfig.sh

chown munin /var/lib/munin/
