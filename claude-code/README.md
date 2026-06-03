# 如何使用这个镜像

## 这是什么

这个目录提供了一个基于 `docker compose` 的 `claude-code` 和 `cc-connect` 运行方案。

容器内部使用 `cc` 用户（`uid=1001`，`gid=1001`）运行，并将运行时数据持久化到宿主机挂载目录中，因此已安装的 CLI 工具和工作区数据在容器重启后仍可复用。

## 目录结构

当前 compose 使用了两个 bind mount：

- `./volumes/cc/` → `/home/cc/`
- `./volumes/workspace/` → `/workspace/`

其中，`cc` 用户的 home 目录包含：

- `/home/cc/.local/`：CLI 安装目录和 npm 全局前缀
- `/home/cc/.claude/`：Claude Code 配置与运行时数据
- `/home/cc/.cc-connect/`：`cc-connect` 运行时数据

初始化阶段还会自动创建两个配置文件：

- `./volumes/cc/.claude/settings.json`
- `./volumes/cc/.cc-connect/config.toml`

## 快速启动

启动服务：

```shell
docker compose up -d
```

当前 compose 栈包含两个服务：

- `claude-code-init`
- `claude-code`

`claude-code-init` 会在主容器启动前运行，确保 `./volumes/cc/` 和 `./volumes/workspace/` 已创建，并且目录属主为 `1001:1001`。

如果下面两个文件不存在，init 服务还会自动创建空文件：

- `./volumes/cc/.claude/settings.json`
- `./volumes/cc/.cc-connect/config.toml`

容器启动后，可以通过下面的命令查看日志：

```shell
docker logs -f claude-code --tail 100
```

如果你需要进入容器：

```shell
docker exec -it claude-code sh
```

## 首次启动行为

首次启动时，入口脚本会检查 `/home/cc/.local/bin/` 下是否已经存在所需的 CLI 工具。

如果不存在，会自动安装：

- `@anthropic-ai/claude-code@stable`
- `cc-connect@latest`

因此，第一次启动通常会比后续重启更慢。

当工具安装完成后，后续重启会直接复用 `./volumes/cc/` 中的已挂载数据，除非你手动删除已有文件，否则不会重复安装。

## 目录与权限说明

主容器运行时使用：

- 用户：`1001:1001`
- Home：`/home/cc`
- 工作目录：`/workspace`

之所以需要 init 服务，是因为 bind mount 会覆盖镜像内已经准备好的目录属主信息。

如果没有初始化步骤，新创建的宿主机目录可能对 `1001:1001` 不可写，从而导致第一次执行 `npm install --prefix /home/cc/.local` 时出现 `EACCES`。

如果你手动修改了挂载目录，请确认宿主机路径仍然对 `1001:1001` 可写。

两个初始化文件的默认行为如下：

- `./volumes/cc/.claude/settings.json`：如果文件不存在，会自动创建为空文件
- `./volumes/cc/.cc-connect/config.toml`：如果文件不存在，会自动创建为空文件

这样做的原因是：

- 不预设任何字段结构，避免默认内容和你的实际配置冲突
- 文件路径会被先准备好，后续你可以直接在宿主机上编辑

后续使用时，直接编辑宿主机上的这两个文件即可，容器重启后会继续复用。

手动填写时可以参考下面的最小内容：

```json
{}
```

```toml
# 在这里填写你的 cc-connect 配置
```

## 常见问题排查

### 首次启动较慢

如果 `/home/cc/.local/bin/claude` 还不存在，这是正常现象。

查看日志：

```shell
docker logs -f claude-code --tail 100
```

如果你看到类似下面的输出：

```text
Installing @anthropic-ai/claude-code@stable into /home/cc/.local
```

说明容器仍在执行首次安装。

### 安装时出现 Permission denied

如果启动时报 `EACCES`，先检查 init 服务是否成功执行：

```shell
docker compose ps
```

然后检查宿主机目录属主：

```shell
ls -ld ./volumes/cc ./volumes/workspace
```

如果有需要，可以手动修正权限：

```shell
sudo chown -R 1001:1001 ./volumes/cc ./volumes/workspace
```

然后重新启动：

```shell
docker compose up -d
```

### Healthcheck 一直不健康

当前 healthcheck 只检查下面这个路径是否存在 `claude`：

```text
/home/cc/.local/bin/claude
```

所以如果首次安装失败，容器会一直保持 unhealthy，直到安装成功。

这时可以通过容器日志确认安装步骤是否已经完成。
