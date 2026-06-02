FROM node:24-alpine

# 运行时通过 --prefix 把 CLI 安装到 cc 的 home 目录，因此需要把该目录加入 PATH
ENV HOME=/home/cc \
    CLAUDE_GLOBAL_PREFIX=/home/cc/.local \
    CLAUDE_CONFIG_HOME=/home/cc/.claude \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    PATH=/home/cc/.local/bin:$PATH

RUN set -eux; \
    apk add --no-cache bash git openssh-client ca-certificates; \
    addgroup -g 1001 -S cc; \
    adduser -u 1001 -S -G cc -h /home/cc cc; \
    # 预创建持久化目录并统一赋权, 避免首次挂载空卷时出现非 root 用户写入失败
    mkdir -p "$CLAUDE_GLOBAL_PREFIX" "$CLAUDE_CONFIG_HOME" "$HOME/.cc-connect" /workspace; \
    chown -R cc:cc "$HOME" /workspace

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
WORKDIR /workspace
USER cc

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/sh"]
