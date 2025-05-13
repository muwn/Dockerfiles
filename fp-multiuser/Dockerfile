FROM --platform=$BUILDPLATFORM golang:alpine AS builder

ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG VERSION
ARG CGO_ENABLED=off

ENV GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    CGO_ENABLED=$CGO_ENABLED

RUN set -eux && \
    apk add --no-cache curl build-base git libcap && \
    mkdir -p /root/fp-multiuser /etc/frp && cd /root/fp-multiuser && \
    curl -sSL https://github.com/gofrp/fp-multiuser/archive/refs/tags/v$VERSION.tar.gz | tar xz --strip 1 && \
    go build -v -ldflags "-s -w" -o /release/fp-multiuser ./cmd/fp-multiuser && \
    ls /release/* | xargs -n1 setcap 'cap_net_bind_service+ep' && \
    echo "admin=admin" > /etc/frp/tokens

FROM alpine:3

RUN set -eux; \
    apk add --no-cache tzdata

COPY --from=builder /release/* /usr/local/bin/
COPY --from=builder /etc/frp/* /etc/frp/

CMD ["/usr/local/bin/fp-multiuser", "-f", "/etc/frp/tokens"]