FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG VERSION
ARG CGO_ENABLED=0

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=$CGO_ENABLED

RUN set -eux && \
    apk add --no-cache curl build-base git libcap && \
    mkdir -p /root/frp /etc/frp && cd /root/frp && \
    curl -sSL https://github.com/fatedier/frp/archive/refs/tags/v$VERSION.tar.gz | tar xz --strip 1 && \
    go build -v -ldflags "-s -w" -o /release/frps ./cmd/frps && \
    ls /release/frp* | xargs -n1 setcap 'cap_net_bind_service+ep' && \
    cp ./conf/frps* /etc/frp/

FROM alpine:3

RUN set -eux; \
    apk add --no-cache tzdata

COPY --from=builder /release/* /usr/local/bin/
COPY --from=builder /etc/frp/* /etc/frp/

CMD ["/usr/local/bin/frps", "-c", "/etc/frp/frps.toml"]