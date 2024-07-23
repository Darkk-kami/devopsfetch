#!/bin/bash

# Define the base directory for the scripts
BASE_DIR="/opt/devopsfetch/scripts"

# Source other scripts
source "$BASE_DIR/docker_info.sh"
source "$BASE_DIR/nginx_info.sh"
source "$BASE_DIR/port_info.sh"
source "$BASE_DIR/system_monitor.sh"
source "$BASE_DIR/time_info.sh"
source "$BASE_DIR/user_info.sh"

# Function to display help message
show_help() {
    echo "Usage: devopsfetch [option] [argument]"
    echo "Options:"
    echo "  -u, --users       List users or details for a specific user"
    echo "  -p, --ports       List ports or details for a specific port"
    echo "  -n, --nginx       List Nginx domains or details for a specific domain"
    echo "  -d, --docker      List Docker images and containers or details for a specific container"
    echo "  -t, --time        Display activities within a specified time range"
    echo "  -h, --help        Show this help message"
}

# Main script logic
case "$1" in
    -u|--users)
        if [ -z "$2" ]; then
            list_users
        else
            user_details "$2"
        fi
        ;;
    -p|--ports)
        if [ -z "$2" ]; then
            display_ports
        else
            display_port_details "$2"
        fi
        ;;
    -n|--nginx)
        if [ -z "$2" ]; then
            nginx_domains
        else
            domain_info "$2"
        fi
        ;;
    -d|--docker)
        if [ -z "$2" ]; then
            list_docker_images_containers
        else
            container_details "$2"
        fi
        ;;
    -t|--time)
        if [ -z "$2" ]; then
            echo "Required: date (YYYY-MM-DD) or date range (YYYY-MM-DD YYYY-MM-DD). Use -h|--help to see valid arguments."
        else
            activity_check "$2" "$3"
        fi
        ;;
    -h|--help)
        show_help
        ;;
    *)
        echo "Invalid option: $1"
        show_help
        exit 1
        ;;
esac
