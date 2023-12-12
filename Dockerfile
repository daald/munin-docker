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

FROM alpine:3.17
# 3.18 munin is not working (dependency to munin-node, and wrong paths in generated html pages)
# 3.18 needs these extra deps: perl-log-log4perl munin-node perl-cgi-fast

MAINTAINER Daniel Alder <daald@users.noreply.github.com>

# Install packages
RUN apk add --no-cache \
	munin \
	dumb-init \
	tzdata \
	spawn-fcgi \
	perl-cgi-fast \
	;
# the last block of packages should not be here (wasn't needed with older version of alpine)


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
RUN chown munin.munin /usr/share/webapps/munin/html

RUN set -ex \
  ; echo verification \
  ; id -u munin \
  ; id -u httpd \
  ;

# Expose nginx
EXPOSE 8080

# Use dumb-init since we run a lot of processes
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run start script or what you choose
CMD /opt/entrypoint.sh