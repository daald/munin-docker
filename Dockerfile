FROM golang:alpine AS compile

ADD server/muninhttpd.go /opt

# go mod init daald/miniwebfcgi && go mod tidy && cat go.mod

RUN set -x \
 && cd /opt/ \
 && echo "module daald/miniwebfcgi" >go.mod \
 && echo "go 1.21.1" >>go.mod \
 && echo "require github.com/yookoala/gofast v0.7.0" >>go.mod \
 && go get -d . \
 && go build muninhttpd.go

FROM alpine:latest

MAINTAINER Daniel Alder <daald@users.noreply.github.com>

# Install packages
RUN apk add --no-cache \
	munin \
	dumb-init \
	tzdata \
	;
#RUN apk add --no-cache \
#  coreutils \
#  dumb-init \
#  findutils \
#  logrotate \
#  munin \
#  perl-cgi-fast \
#  procps \
#  rrdtool-cached \
#  spawn-fcgi \
#  sudo \
#  ttf-opensans \
#  tzdata \
#  ;

#ADD entrypoint.sh bootstrap server updater /opt/
ADD entrypoint.sh /opt/

#---------
ADD bootstrap /opt/bootstrap

#---------
ADD server /opt/server
COPY --from=compile /opt/muninhttpd /opt/server/
#RUN groupadd -g 2001 httpd && useradd -m -u 2001 -g httpd httpd
RUN adduser --system httpd

#---------
ADD updater /opt/updater
#RUN groupadd -g 2002 munin && useradd -m -u 2002 -g munin munin
#RUN adduser --system munin

# Expose nginx
EXPOSE 8080

# Use dumb-init since we run a lot of processes
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run start script or what you choose
CMD /opt/entrypoint.sh
