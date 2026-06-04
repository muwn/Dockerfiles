# 如何使用这个镜像

## 这是什么

这个目录提供了一个基于官方 `nginx` 镜像的自定义镜像，构建时可以指定基础镜像版本。

在保留官方默认配置结构的基础上，这个镜像额外做了几件事：

- 设置时区为 `Asia/Shanghai`
- 设置 `LANG=C.UTF-8`
- 安装常用排障工具
- 为 `nginx.conf` 增加 `stream` 配置块，并默认读取 `/etc/nginx/conf.d/*.stream`
- 移除官方镜像默认的日志软链接，改为真实日志文件
- 为错误日志显式增加 `/dev/stderr` 输出，避免挂载 `/var/log/nginx` 后 `docker logs` 丢失错误日志

## 镜像内额外安装的工具

镜像中安装了以下工具：

- `vim`
- `wget`
- `telnet`
- `tcpdump`
- `net-tools`
- `tree`
- `iputils-ping`
- `lsof`
- `iproute2`
- `procps`

同时会关闭 `vim` 默认鼠标模式，避免终端复制时被鼠标模式抢占。

## 构建镜像

默认使用官方 `nginx:latest` 作为基础镜像：

```shell
docker build -t muwn/nginx:latest ./nginx
```

如果你希望显式指定基础镜像版本，可以传入 `NGINX_VERSION`：

```shell
docker build \
  --build-arg NGINX_VERSION=1.28.0 \
  -t muwn/nginx:1.28.0 \
  ./nginx
```

## GitHub Actions 构建

仓库里的 `nginx` workflow 只保留一个手动输入参数：

- `nginx_version`：上游基础镜像版本，例如 `latest`、`1.28.0`

这个值会同时作为：

- `Dockerfile` 的 `NGINX_VERSION` 构建参数
- 你发布到 Docker Hub 的镜像版本号

例如当你填写 `1.28.0` 时，workflow 会构建：

- 基础镜像：`nginx:1.28.0`
- 目标镜像：`muwn/nginx:1.28.0`

## 快速启动

如果只想直接启动一个容器：

```shell
docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  muwn/nginx:latest
```

查看日志：

```shell
docker logs -f nginx
```

进入容器：

```shell
docker exec -it nginx sh
```

## 配置文件说明

这个镜像仍然沿用官方 `nginx` 的默认加载方式：

- HTTP 配置：`/etc/nginx/conf.d/*.conf`
- Stream 配置：`/etc/nginx/conf.d/*.stream`

也就是说：

- 你自己的 HTTP 配置文件请使用 `.conf` 后缀
- 你自己的 TCP/UDP 代理配置请使用 `.stream` 后缀

例如：

```text
/etc/nginx/conf.d/
├── default.conf
├── app.conf
└── mysql.stream
```

## 仓库内附带的示例片段

当前目录额外提供了两个可复用的示例片段：

- `http.conf`
- `stream.stream`

它们的用途分别是：

- `http.conf`：定义 HTTP 层的基础限流配置，以及可复用的 OSS 本地代理缓存区
- `stream.stream`：让 stream access log 输出到 `/dev/stdout`

如果你希望启用对应能力，可以把它们挂载到 `/etc/nginx/conf.d/` 中。

示例：

```shell
docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  -v "$(pwd)/nginx/http.conf:/etc/nginx/conf.d/http.conf:ro" \
  -v "$(pwd)/nginx/stream.stream:/etc/nginx/conf.d/stream.stream:ro" \
  muwn/nginx:latest
```

## OSS 文件缓存定义

`http.conf` 中已经包含下面这条缓存区定义：

```nginx
proxy_cache_path /var/cache/nginx/oss levels=1:2 keys_zone=oss_file_cache:100m max_size=10g inactive=7d use_temp_path=off;
```

这样做的好处是：

- 基础镜像只提供缓存能力，不强绑定具体路由
- 你可以在自己的 `server` / `location` 中按需启用
- 同一个缓存区可以被多个文件下载 location 复用

如果你要在某个文件下载路径启用缓存，可以在你自己的站点配置中引用：

```nginx
location /oss/ {
    proxy_pass https://static.example.com/;
    proxy_set_header Host static.example.com;
    proxy_set_header Connection "";

    proxy_http_version 1.1;
    proxy_buffering on;
    proxy_request_buffering on;

    proxy_cache oss_file_cache;
    proxy_cache_methods GET HEAD;
    proxy_cache_key "$scheme$proxy_host$request_uri";
    proxy_cache_lock on;
    proxy_cache_lock_timeout 10s;
    proxy_cache_revalidate on;
    proxy_cache_background_update on;
    proxy_cache_use_stale error timeout invalid_header updating http_500 http_502 http_503 http_504;

    proxy_cache_valid 200 206 301 302 1h;
    proxy_cache_valid 404 10m;

    add_header X-Proxy-Cache $upstream_cache_status always;
    expires 1h;
    add_header Cache-Control "public, max-age=3600" always;
}
```

如果你需要持久化缓存文件，建议额外挂载缓存目录：

```shell
mkdir -p ./cache/nginx/oss

docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  -v "$(pwd)/nginx/http.conf:/etc/nginx/conf.d/http.conf:ro" \
  -v "$(pwd)/cache/nginx/oss:/var/cache/nginx/oss" \
  muwn/nginx:latest
```

## 日志行为

这个镜像对日志做了两点调整：

### 1. 默认日志软链接已移除

官方镜像通常会把：

- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`

做成指向标准输出/错误的软链接。

这个镜像会移除这两个软链接，并创建为真实文件。

这样做的好处是：

- 后续挂载 `/var/log/nginx` 时行为更直接
- 不再依赖官方镜像默认的软链接机制
- 日志文件更符合常规文件系统预期

### 2. 错误日志仍然进入 `docker logs`

虽然默认软链接已经移除，但镜像会在 `nginx.conf` 中额外追加：

```nginx
error_log /dev/stderr notice;
```

因此即使你挂载了 `/var/log/nginx`，错误日志仍然可以通过下面的命令查看：

```shell
docker logs -f nginx
```

### 3. Stream 访问日志默认落文件

stream 访问日志默认写入：

```text
/var/log/nginx/tcp-access.log
```

如果你还希望它同时输出到 `docker logs`，可以挂载仓库中的 `stream.stream` 示例片段。

## 挂载日志目录示例

如果你希望把日志持久化到宿主机：

```shell
mkdir -p ./logs

docker run -d \
  --name nginx \
  -p 80:80 \
  -p 443:443 \
  -v "$(pwd)/logs:/var/log/nginx" \
  muwn/nginx:latest
```

这样容器内的日志会写入宿主机 `./logs/`。

如果同时需要让访问日志继续进入 `docker logs`，请额外挂载上面的 `http.conf` 和 `stream.stream`。

## 宿主机 logrotate 示例

如果你已经把日志目录挂载到宿主机，最简单的做法是在宿主机上配置 `logrotate`。

例如，把下面的内容保存为：

```text
/etc/logrotate.d/docker-nginx
```

示例配置：

```conf
/path/to/logs/*.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    dateext
    copytruncate
}
```

字段含义：

- `daily`：每天轮转一次
- `rotate 7`：最多保留 7 份历史日志
- `compress`：对历史日志进行压缩
- `delaycompress`：从下一次轮转开始压缩，避免刚切分就压缩最新旧文件
- `copytruncate`：先复制再清空原文件，避免轮转时需要容器内显式 reopen 日志文件

如果你希望使用更稳妥的方式，而不是 `copytruncate`，也可以改成下面这种：

```conf
/path/to/logs/*.log {
    daily
    rotate 7
    missingok
    notifempty
    compress
    delaycompress
    dateext
    sharedscripts
    postrotate
        docker exec nginx nginx -s reopen >/dev/null 2>&1 || true
    endscript
}
```

这种方式更适合高写入日志场景，因为它会让 Nginx 主动重新打开日志文件。

如果你的容器名不是 `nginx`，请把上面的 `docker exec nginx` 改成实际容器名。
