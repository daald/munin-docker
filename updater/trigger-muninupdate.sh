#!/bin/sh

logfile="/var/log/munin/munin-update.log"
lastlogpos="$(stat -c%s "$logfile" 2>/dev/null || echo 0)"

/usr/bin/munin-cron

if [ -n "$SMTPHOST" ]; then
  if [ -s /etc/munin/update-error-whitelist.regex ]; then
    whitelist() {
      grep -vEf /etc/munin/update-error-whitelist.regex
    }
  else
    whitelist() {
      cat
    }
  fi
  tail -c+"$lastlogpos" "$logfile" | grep -E '\[(WARNING|ERROR|FATAL)\]' >/tmp/muninupdate-lastcall | whitelist
  if [ -s /tmp/muninupdate-lastcall ]; then
    cat /tmp/muninupdate-lastcall | sendmail "$SMTPTO"
  fi
fi
