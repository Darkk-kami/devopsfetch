#!/bin/bash

list_docker_images_containers() {
    echo -e "\nDocker Images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}"

    echo -e "\nDocker Containers:"
    docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
}

container_details() {
    CONTAINER_NAME=$1
    echo "Showing Details for Docker Container: $CONTAINER_NAME"
    echo "......................................................."
    container_id=$(docker ps -a --filter "name=$CONTAINER_NAME" --format "{{.ID}}")

    if [[ -z $container_id ]]; then
        echo "Container $CONTAINER_NAME does not exist."
        return
    fi

    docker inspect "$container_id" | jq '.[0] | {
        ID: .Id,
        Name: .Name,
        Image: .Config.Image,
        Command: .Config.Cmd,
        Created: .Created,
        Status: .State.Status,
        Ports: .NetworkSettings.Ports,
        Mounts: .Mounts
    }'
}