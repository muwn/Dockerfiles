FROM --platform=$BUILDPLATFORM node:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG VERSION
ARG CGO_ENABLED=0

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=$CGO_ENABLED

RUN set -eux && \
    apk add --no-cache curl build-base git libcap go && \
    mkdir -p /root/filebrowser  /etc/filebrowser && cd /root/filebrowser && \
    git clone -b v${VERSION} https://github.com/filebrowser/filebrowser.git --depth=1 . && \
    cd frontend && npm install -g pnpm && npm install && npm run build && cd - && \
    VERSION_HASH=$(git rev-parse HEAD) && \
    MODULE=$(env GO111MODULE=on go list -m) && \
    go build -v -ldflags "-s -w -X ${MODULE}/version.Version=${VERSION} -X ${MODULE}/version.CommitSHA=${VERSION_HASH}" -o /release/filebrowser && \
    cp docker_config.json /etc/filebrowser/settings.json && \
    ls /release/filebrowser* | xargs -n1 setcap 'cap_net_bind_service+ep'

FROM alpine:3

RUN set -eux; \
    apk add --no-cache tzdata

COPY --from=builder /release/* /usr/local/bin/
COPY --from=builder /etc/filebrowser/* /etc/filebrowser/

CMD ["/usr/local/bin/filebrowser", "-c", "/etc/filebrowser/settings.json"]