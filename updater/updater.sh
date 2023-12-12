#!/bin/sh

# @reboot         munin if [ -x /usr/bin/munin-cron ]; then /usr/bin/munin-cron; fi
# */5 * * * *     munin if [ -x /usr/bin/munin-cron ]; then /usr/bin/munin-cron; fi

sleep 3  # delayed start
exec /opt/updater/minicron
