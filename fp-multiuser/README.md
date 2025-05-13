# How to use this image

## Start an instance

``` shell
docker run -d --name fp-multiuser -p 7200:7200 muwn/fp-multiuser:latest
```

## if youer want to use your own configuration

### Mount your configuration file
``` shell
cat > ./volume/fp-multiuser/tokens <<"EOF"
admin=admin
user1=user1
EOF

docker run -d --name fp-multiuser -p 7200:7200 -v ./volume/fp-multiuser/tokens:/etc/fp-multiuser/tokens muwn/fp-multiuser:latest
```

## via [docker compose](https://github.com/docker/compose)

```shell
# frps.toml Additional content 
cat >> ./volume/frp/frps.toml <<"EOF"

# multiuser plugin
[[httpPlugins]]
name = "multiuser"
addr = "fp-multiuser:7200" # plugin server
path = "/handler"
ops = ["Login"] # @see https://gofrp.org/zh-cn/docs/features/common/server-plugin/
EOF

wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/fp-multiuser/docker-compose.yaml -O docker-compose.yaml
```