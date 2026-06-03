# 如何使用这个镜像

## 这是什么

这个目录提供了一个基于官方 `nginx:latest` 的自定义镜像。

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

```shell
docker build -t muwn/nginx:latest ./nginx
```

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

- `http.conf`：关闭 `server_tokens`，并让 HTTP access log 输出到 `/dev/stdout`
- `stream.stream`：让 stream access log 输出到 `/dev/stdout`

如果你希望访问日志同时进入 `docker logs`，可以把它们挂载到 `/etc/nginx/conf.d/` 中。

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
