FROM golang:1.10.3-alpine3.7 as build-container

ENV GITEA_VER="v1.5.0-rc2"
ENV TAGS="bindata redis"

# The build container
RUN apk add -U build-base git && \
    go get -d -u code.gitea.io/gitea && \
    cd $GOPATH/src/code.gitea.io/gitea && \
    git checkout tags/$GITEA_VER && \
    make clean generate build

# The release container
FROM alpine:3.7

RUN addgroup git && \
    adduser -D -h /opt -G git git && \
    echo "git:`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 | mkpasswd -m sha256`" | chpasswd && \
    apk add -U --no-cache git openssh-keygen

COPY --from=build-container /go/src/code.gitea.io/gitea/custom /opt/custom
COPY --from=build-container /go/src/code.gitea.io/gitea/gitea /opt/gitea

RUN chown git:git -R /opt

ENV USER=git
CMD /opt/gitea web
