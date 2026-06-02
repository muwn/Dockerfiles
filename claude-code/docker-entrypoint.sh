#!/bin/sh
set -eu

# 挂载空卷会覆盖镜像内预创建目录，这里在启动时兜底创建一次
mkdir -p "$CLAUDE_GLOBAL_PREFIX" "$CLAUDE_CONFIG_HOME" "$HOME/.cc-connect"

install_if_missing() {
    binary_name="$1"
    package_name="$2"

    if [ -x "$CLAUDE_GLOBAL_PREFIX/bin/$binary_name" ]; then
        return
    fi

    mkdir -p "$CLAUDE_GLOBAL_PREFIX"
    # 首次挂空卷时输出安装日志，便于区分网络安装耗时与容器启动异常
    echo "Installing $package_name into $CLAUDE_GLOBAL_PREFIX"
    npm install -g --prefix "$CLAUDE_GLOBAL_PREFIX" "$package_name"
}

install_if_missing claude @anthropic-ai/claude-code@stable
install_if_missing cc-connect cc-connect@latest

if [ "$#" -eq 0 ]; then
    set -- /bin/sh
fi

exec "$@"
