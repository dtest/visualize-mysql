
## Dependencies
- Docker Toolbox

## Create docker machine

```
$ docker-machine create -d virtualbox --virtualbox-memory "2048" --virtualbox-cpu-count "2" visualize
$ eval $(docker-machine env visualize)
```

## Start the services
```
$ docker-compose up -d
```

## Go to Kibana and Graphana

First, you will need to know what IP your docker-machine is running on. You can get this from:

```
$ eval $(docker-machine env visualize)
$ env | grep DOCKER_HOST
```

- Kibana: http://$DOCKER_HOST:9292
- Graphana: http://$DOCKER_HOST:8000

Graphana default credentials are:
- user: admin
- pass: admin