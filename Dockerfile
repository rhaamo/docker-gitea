FROM golang:1.12.0-alpine3.9 as build-container

ENV GITEA_VER="1.7.3"
ENV TAGS="bindata redis"

# The build container
RUN apk add -U build-base git && \
    go get -d -u code.gitea.io/gitea && \
    cd $GOPATH/src/code.gitea.io/gitea && \
    git checkout tags/v$GITEA_VER && \
    make clean generate build

# The release container
FROM alpine:3.9

RUN addgroup git && \
    adduser -D -S -u 1000 -h /opt -G git git && \
    apk add -U --no-cache git openssh-keygen

COPY --from=build-container /go/src/code.gitea.io/gitea/custom /opt/custom
COPY --from=build-container /go/src/code.gitea.io/gitea/gitea /opt/gitea

RUN chown git:git -R /opt

USER git
ENV USER=git
CMD /opt/gitea web
