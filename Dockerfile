FROM alpine:3.7

ENV GITEA_VER="v1.4.0"
ENV GOPATH="/opt/git/go"

RUN addgroup git && \
    mkdir /opt && \
    adduser -D -h /opt/git \
        -s /bin/bash -G git git && \
    echo "git:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

RUN apk add -U --virtual deps go \
        make musl-dev && \
    apk add git bash openssh && \
    su - -s /bin/bash git -c \ " \
        go get -d -u code.gitea.io/gitea && \
        cd $GOPATH/src/code.gitea.io/gitea && \
        git checkout tags/$GITEA_VER && \
        PATH=$PATH:$GOPATH/bin \
            make clean generate build -j$(nproc)" && \
    apk del --purge deps && \
    rm -rf $GOPATH/src/code.gitea.io/gitea/.git* && \
    rm -rf ~/go/pkg/ && \
    rm -rf $GOPATH/src/code.gitea.io/gitea/vendor

USER git
CMD /opt/git/go/src/code.gitea.io/gitea/gitea web
