#!/bin/sh

# Usage:
# ./scripts/psql_docker.sh start|stop|create [db_username] [db_password]

cmd=$1           # create | start | stop
db_username=$2   # for create
db_password=$3   # for create

# 1) Ensure docker service is running
# This is like you manually doing: sudo systemctl start docker
sudo systemctl status docker >/dev/null 2>&1 || sudo systemctl start docker

# 2) Check if jrvs-psql container exists
# This is like you doing: docker container inspect jrvs-psql
docker container inspect jrvs-psql >/dev/null 2>&1
container_status=$?   # 0 -> exists, non-zero -> does not exist

case "$cmd" in
  create)
    # If container already exists -> error
    if [ $container_status -eq 0 ]; then
      echo 'Container already exists'
      exit 1
    fi

    # Need exactly 3 args: create user password
    if [ $# -ne 3 ]; then
      echo 'Usage: ./scripts/psql_docker.sh create db_username db_password'
      exit 1
    fi

    # 3) Create volume (what you did: docker volume create pgdata)
    docker volume create pgdata

    # 4) Run container (your docker run command)
    docker run --name jrvs-psql \
      -e POSTGRES_USER="$db_username" \
      -e POSTGRES_PASSWORD="$db_password" \
      -d -v pgdata:/var/lib/postgresql/data \
      -p 5432:5432 postgres:9.6-alpine

    exit $?
    ;;

  start|stop)
    # Must have container created
    if [ $container_status -ne 0 ]; then
      echo 'Container does not exist'
      exit 1
    fi

    # 5) Start or stop container (what you did: docker container start/stop jrvs-psql)
    docker container "$cmd" jrvs-psql
    exit $?
    ;;

  *)
    echo 'Illegal command'
    echo 'Commands: start|stop|create'
    exit 1
    ;;
esac

