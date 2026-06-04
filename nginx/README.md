# 如何使用这个镜像

## 这是什么

这个目录提供了一个基于官方 `nginx` 镜像的自定义镜像，构建时可以指定基础镜像版本。

在保留官方默认配置结构的基础上，这个镜像额外做了几件事：

- 设置时区为 `Asia/Shanghai`
- 设置 `LANG=C.UTF-8`
- 安装常用排障工具
- 为 `nginx.conf` 增加 `stream` 配置块，并默认读取 `/etc/nginx/conf.d/*.stream`
- 关闭 `server_tokens`
- 为 HTTP access log 显式增加 `/dev/stdout` 输出
- 为 error log 显式增加 `/dev/stderr` 输出
- 移除官方镜像默认日志软链接，改为真实文件

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

## 当前目录结构

当前 `docker-compose.yaml` 使用下面三个宿主机挂载目录：

- `./volumes/conf.d/` → `/etc/nginx/conf.d/`
- `./volumes/logs/` → `/var/log/nginx/`
- `./volumes/cache/` → `/var/cache/nginx/`

建议至少准备成下面这样：

```text
./volumes/
├── cache/
├── conf.d/
│   ├── http.conf
│   └── stream.stream
└── logs/
```

其中：

- `http.conf`：定义 HTTP 层的限流配置和可复用的 OSS 缓存区
- `stream.stream`：定义 stream 层补充配置

你可以直接复用当前目录里的这两个文件作为初始配置。

## docker-compose.yaml

当前目录已提供可直接使用的：

```text
docker-compose.yaml
```

启动前建议先准备目录：

```shell
mkdir -p ./volumes/conf.d ./volumes/logs ./volumes/cache
cp ./http.conf ./volumes/conf.d/http.conf
cp ./stream.stream ./volumes/conf.d/stream.stream
```

启动方式：

```shell
docker compose up -d
```

停止并移除容器：

```shell
docker compose down
```

## 健康检查

当前 `docker-compose.yaml` 已内置健康检查，策略是访问容器内的 HTTP 端口：

```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -s http://127.0.0.1:80 > /dev/null 2>&1"]
```

这个检查方式会直接验证 HTTP 服务是否已经起来，但它只覆盖容器内的 `80` 端口，不替代完整的配置正确性校验。

## 日志与缓存目录

运行时目录用途如下：

- `/etc/nginx/conf.d/`：额外的 HTTP / stream 配置
- `/var/log/nginx/`：访问日志、错误日志、stream 日志
- `/var/cache/nginx/`：缓存目录，当前 `http.conf` 默认会使用 `/var/cache/nginx/oss`

查看容器日志：

```shell
docker logs -f nginx
```

进入容器：

```shell
docker exec -it nginx sh
```
