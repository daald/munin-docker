#!/bin/sh

# @reboot         munin if [ -x /usr/bin/munin-cron ]; then /usr/bin/munin-cron; fi
# */5 * * * *     munin if [ -x /usr/bin/munin-cron ]; then /usr/bin/munin-cron; fi

set -x #T

sleep 2  # delayed start
echo update.
/usr/bin/munin-cron
tail -n10 /var/log/munin/munin-update.log  #T
#find /var/lib/munin/  #T

while sleep 300; do
  echo update.
  /usr/bin/munin-cron
done
