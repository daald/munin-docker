#!/bin/sh


# http://localhost:8080/munin/static/

docker-compose up --build

exit $?


set -ex

docker build munin-server4 -t munin-server4:test

docker run --rm -h muninserver munin-server4:test
