#!/bin/bash

BASE_DIR="/opt/devopsfetch/scripts"
# Source other scripts
source "$BASE_DIR/docker_info.sh"
source "$BASE_DIR/nginx_info.sh"
source "$BASE_DIR/port_info.sh"
source "$BASE_DIR/system_monitor.sh"
source "$BASE_DIR/time_info.sh"
source "$BASE_DIR/user_info.sh"

print_help() {
    echo "Usage: devopsfetch [OPTIONS]"
    echo
    echo "Options:"
    echo "  -p, --port [PORT_NUMBER]       Display all active ports and services or detailed information about a specific port"
    echo "  -d, --docker [CONTAINER_NAME]  List all Docker images and containers or provide detailed information about a specific container"
    echo "  -n, --nginx [DOMAIN]           Display all Nginx domains and their ports or detailed configuration information for a specific domain"
    echo "  -u, --users [USERNAME]         List all users and their last login times or provide detailed information about a specific user"
    echo "  -t, --time [START_DATE] [END_DATE] Display activities within a specified time range"
    echo "  -h, --help                     Display this help message"
}

if [ $# -eq 0 ]; then
    print_help
    exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--port)
            if [[ -n $2 && $2 != -* ]]; then
                display_port_details "$2"
                shift 2
            else
                display_ports
                shift 1
            fi
            ;;
        -d|--docker)
            if [[ -n $2 && $2 != -* ]]; then
                container_details "$2"
                shift 2
            else
                list_docker_images_containers
                shift 1
            fi
            ;;
        -n|--nginx)
            if [[ -n $2 && $2 != -* ]]; then
                domain_info "$2"
                shift 2
            else
                nginx_domains
                shift 1
            fi
            ;;
        -u|--users)
            if [[ -n $2 && $2 != -* ]]; then
                user_details "$2"
                shift 2
            else
                list_users
                shift 1
            fi
            ;;
        -t|--time)
            if [[ -n $2 && $2 != -* ]]; then
                activity_check "$2" "$3"
                shift 3
            else
                echo "Error: -t|--time requires a start date and optionally an end date."
                exit 1
            fi
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "Error: Invalid option '$1'"
            print_help
            exit 1
            ;;
    esac
done
