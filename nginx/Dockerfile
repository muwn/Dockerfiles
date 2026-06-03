FROM nginx:latest

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8

# 源更新，按当前 nginx:latest 使用的 Debian sources 文件格式直接替换
RUN set -eux; \
    sed -i 's#deb.debian.org#mirrors.ustc.edu.cn#g' /etc/apt/sources.list.d/debian.sources; \
    sed -i 's#security.debian.org#mirrors.ustc.edu.cn#g' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y

# 时区
RUN set -eux; \
    apt-get install -y --no-install-recommends tzdata; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone

# 工具集
RUN set -eux; \
    apt-get install -y --no-install-recommends vim wget telnet tcpdump net-tools tree iputils-ping lsof iproute2 procps

# vim 鼠标模式转可视模式，避免终端复制时被鼠标模式抢占
RUN set -eux; \
    vim_default_path=$(find /usr/share/vim/ -name defaults.vim | head -n 1); \
    if [ -n "$vim_default_path" ]; then \
        sed -i 's/set mouse=.*/set mouse=""/' "$vim_default_path"; \
    fi

# 添加 stream 支持，默认读取 /etc/nginx/conf.d/*.stream
RUN set -eux; \
    cat > /tmp/nginx-stream.conf <<'EOF' && \
stream {
    # see https://nginx.org/en/docs/varindex.html
    log_format main '$remote_addr [$time_local] '
                     '$protocol $status $bytes_sent $bytes_received '
                     '$session_time "$upstream_addr" '
                     '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /var/log/nginx/tcp-access.log main;

    # see https://nginx.org/en/docs/http/ngx_http_log_module.html#open_log_file_cache
    open_log_file_cache max=1000 inactive=20s valid=1m min_uses=2;

    include /etc/nginx/conf.d/*.stream;
}
EOF
    cat /tmp/nginx-stream.conf >> /etc/nginx/nginx.conf; \
    rm -f /tmp/nginx-stream.conf

# 关闭 Nginx 版本信息
RUN set -eux; \
    sed -i '/http {/a\    server_tokens off;' /etc/nginx/nginx.conf

# 清理缓存
RUN set -eux; \
    apt-get autoremove -y; \
    apt-get autoclean; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*
