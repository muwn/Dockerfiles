
# frps

# Use

## Use Docker

``` shell
docker run -d --name frps -p 7000:7010 -v ./volume/frp/frps.toml:/ect/frp/frps.toml muwn/frps:latest
```

## Use Docker Compose

```shell
wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/frps/docker-compose.yml
docker-compose up -d
```
