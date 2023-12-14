#!/bin/sh

logfile="/var/log/munin/munin-update.log"
lastlogpos="$(stat -c%s "$logfile" 2>/dev/null || echo 0)"

/usr/bin/munin-cron

if [ -n "$SMTPHOST" ]; then
  tail -c+"$lastlogpos" "$logfile" | grep -E '\[(WARNING|ERROR|FATAL)\]' >/tmp/muninupdate-lastcall
  if [ -s /tmp/muninupdate-lastcall ]; then
    cat /tmp/muninupdate-lastcall | sendmail "$SMTPTO"
  fi
fi
