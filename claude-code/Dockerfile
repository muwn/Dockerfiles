FROM node:24-alpine

ENV CLAUDE_GLOBAL_PREFIX=/opt/claude-global \
    CLAUDE_CONFIG_HOME=/root/.claude \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    PATH=/opt/claude-global/bin:$PATH

RUN set -eux; \
    apk add --no-cache bash git openssh-client ca-certificates; \
    mkdir -p "$CLAUDE_GLOBAL_PREFIX" "$CLAUDE_CONFIG_HOME" /workspace

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
WORKDIR /workspace

VOLUME ["/opt/claude-global", "/root/.claude", "/workspace"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/sh"]
