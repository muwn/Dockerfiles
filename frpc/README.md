# How to use this image

## Start an instance

``` shell
docker run -d --name frpc -p 7000:7010 muwn/frpc:latest
```

## if youer want to use your own configuration

If you wish to adapt the default configuration, use something like the following to get it from a frpc container:

```shell
# Default
docker run --rm muwn/frpc:latest cat /etc/frp/frpc.toml > ./volume/frp/frpc.toml
# Full Example
docker run --rm muwn/frpc:latest cat /etc/frp/frpc_full_example.toml > ./volume/frp/frpc_full_example.toml
```

### Mount your configuration file
``` shell
docker run -d --name frpc -p 7000:7010 -v ./volume/frp/frpc.toml:/ect/frp/frpc.toml muwn/frpc:latest
```

## via [docker compose](https://github.com/docker/compose)

```shell
wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/frpc/docker-compose.yaml -O docker-compose.yaml
```