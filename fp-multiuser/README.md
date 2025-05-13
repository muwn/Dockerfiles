# How to use this image

## Start an instance

``` shell
docker run -d --name fp-multiuser -p 7200:7200 muwn/fp-multiuser:latest
```

## if youer want to use your own configuration

### Mount your configuration file
``` shell
cat > tokens <<"EOF"
admin=admin
user1=user1
EOF

docker run -d --name fp-multiuser -p 7200:7200 -v ./volume/frp/tokens:/etc/frp/tokens muwn/fp-multiuser:latest
```

## via [docker compose](https://github.com/docker/compose)

```shell
wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/fp-multiuser/docker-compose.yaml -O docker-compose.yaml
```