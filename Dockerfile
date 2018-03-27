FROM alpine:3.7

ENV GITEA_VER="v1.4.0"
ENV GOPATH="/opt/go"

RUN apk add -U --virtual deps go \
		make musl-dev && \
	apk add git && \
	go get -d -u code.gitea.io/gitea && \
	cd $GOPATH/src/code.gitea.io/gitea && \
	git checkout tags/$GITEA_VER && \
	PATH=$PATH:$GOPATH/bin \
		make clean generate build -j$(nproc) && \
	apk del --purge deps && \
	rm -rf $GOPATH/src/code.gitea.io/gitea/.git* && \
	rm -rf ~/go/pkg/ && \
	rm -rf $GOPATH/src/code.gitea.io/gitea/vendor
