#!/bin/bash

set -e

docker swarm init
docker network create --driver overlay caddy
docker stack deploy --compose-file caddy/stack.yml caddy
docker stack deploy --compose-file stack.yml bunjgames
