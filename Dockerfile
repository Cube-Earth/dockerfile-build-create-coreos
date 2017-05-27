FROM alpine:latest

RUN apk add --update wget ca-certificates gnupg bash && \
	adduser -D -g '' -s /sbin/nologin downloader

ADD VBoxManage run.sh /usr/local/bin/

USER downloader
WORKDIR /tmp

VOLUME /VMs/CoreOS

ENTRYPOINT [ "/usr/local/bin/run.sh" ]
