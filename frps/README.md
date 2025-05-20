# How to use this image

## Start an instance

``` shell
docker run -d --name frps -p 7000:7010 muwn/frps:latest
```

## if youer want to use your own configuration

If you wish to adapt the default configuration, use something like the following to get it from a frps container:

```shell
mkdir -p ./volumes/frp
# Default
docker run --rm muwn/frps:latest cat /etc/frp/frps.toml > ./volumes/frp/frps.toml
# Full Example
docker run --rm muwn/frps:latest cat /etc/frp/frps_full_example.toml > ./volumes/frp/frps_full_example.toml
```

### Mount your configuration file
``` shell
docker run -d --name frps -p 7000:7010 -v ./volumes/frp/frps.toml:/ect/frp/frps.toml muwn/frps:latest
```

## via [docker compose](https://github.com/docker/compose)

```shell
wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/frps/docker-compose.yaml -O docker-compose.yaml
```

## If you want to use multiple users

[fp-multiuser](https://hub.docker.com/r/muwn/fp-multiuser)