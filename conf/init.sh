#!/bin/bash

set -e

docker swarm init
docker network create --driver overlay caddy
docker stack deploy --compose-file ./caddy/stack.yaml caddy
docker stack deploy --compose-file stack.yaml bunjgames
