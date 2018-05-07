FROM golang:1.10.2-alpine as build-container

ENV GITEA_VER="v1.4.1"

# The build container
RUN apk add -U make musl-dev git && \
    go get -d -u code.gitea.io/gitea && \
    cd $GOPATH/src/code.gitea.io/gitea && \
    git checkout tags/$GITEA_VER && \
    PATH=$PATH:$GOPATH/bin \
        make clean generate build -j$(nproc)

# The release container
FROM alpine:3.7

RUN addgroup git && \
    adduser -D -h /opt -s /bin/bash -G git git && \
    echo "git:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd

COPY --from=build-container /go/src/code.gitea.io/gitea/gitea /opt/gitea
COPY --from=build-container /go/src/code.gitea.io/gitea/custom /opt/custom
COPY --from=build-container /go/src/code.gitea.io/gitea/assets /opt/assets
COPY --from=build-container /go/src/code.gitea.io/gitea/public /opt/public
COPY --from=build-container /go/src/code.gitea.io/gitea/templates /opt/templates
COPY --from=build-container /go/src/code.gitea.io/gitea/options /opt/options
RUN apk add -U git bash && \
    chown git:git -R /opt

USER git
CMD /opt/gitea web
