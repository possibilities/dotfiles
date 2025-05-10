#!/bin/sh

# Stop and remove all containers
docker stop $(docker ps -aq)
docker rm -f $(docker ps -aq)

# Remove all images
docker rmi -f $(docker images -q)

# Remove volumes, networks and other Docker resources
docker volume prune -f
docker network prune -f
docker system prune -af --volumes
docker builder prune -af

# Remove Docker Compose volumes, cache and data
rm -rf ~/.docker/compose/
sudo rm -rf /var/lib/docker/volumes/*
sudo rm -rf /var/lib/docker/overlay2/*
sudo rm -rf /var/lib/docker/containers/*

# Clear Docker config and cache files
rm -rf ~/.config/docker/
rm -rf ~/.cache/docker/
