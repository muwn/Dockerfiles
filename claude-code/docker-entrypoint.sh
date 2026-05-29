#!/bin/sh
set -eu

if [ ! -x "$CLAUDE_GLOBAL_PREFIX/bin/claude" ]; then
    mkdir -p "$CLAUDE_GLOBAL_PREFIX"
    npm install -g --prefix "$CLAUDE_GLOBAL_PREFIX" @anthropic-ai/claude-code@stable
fi

if [ ! -x "$CLAUDE_GLOBAL_PREFIX/bin/cc-connect" ]; then
    mkdir -p "$CLAUDE_GLOBAL_PREFIX"
    npm install -g --prefix "$CLAUDE_GLOBAL_PREFIX" cc-connect@latest
fi

if [ "$#" -eq 0 ]; then
    set -- /bin/sh
fi

exec "$@"
