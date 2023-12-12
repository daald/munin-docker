#!/bin/sh
# intended for testing


# http://localhost:8080/munin/

exec docker-compose up --build

exit $?


set -ex

docker build munin-server4 -t munin-server4:test

docker run --rm -h muninserver munin-server4:test
