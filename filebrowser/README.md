# How to use this image

## Start an instance

``` shell
docker run -d --name filebrowser -p 8080:80 muwn/filebrowser:latest
```

## if youer want to use your own configuration

If you wish to adapt the default configuration, use something like the following to get it from a filebrowser container:

```shell
# Default
docker run --rm muwn/filebrowser:latest cat /etc/filebrowser/settings.json > ./volume/filebrowser/settings.json
```

### Mount your configuration file
``` shell
docker run -d --name filebrowser -p 8080:80 -v ./volume/filebrowser/settings.json:/ect/filebrowser/settings.json muwn/filebrowser:latest
```

## via [docker compose](https://github.com/docker/compose)

```shell
wget https://raw.githubusercontent.com/muwn/Dockerfiles/refs/heads/master/filebrowser/docker-compose.yaml -O docker-compose.yaml
```