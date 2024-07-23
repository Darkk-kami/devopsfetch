#!/bin/bash

# Function to list Docker images and containers
list_docker_images_containers() {
    echo -e "\nDocker Images:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}"

    echo -e "\nDocker Containers:"
    docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
}

# Function to show container details
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

# Function to list Nginx domains and their ports
nginx_domains() {
    echo -e "DOMAIN\t\t\tPROXY_PASS_URL"
    grep -E "\bserver_name\b|\bproxy_pass\b" /etc/nginx/sites-enabled/* | awk '
    /server_name/ {domain=$3; gsub(";", "", domain); next}
    /proxy_pass/ {url=$3; gsub(";", "", url); print domain "\t" url}' | column -t
}

# Function to display detailed configuration information for a specific domain
domain_info() {
    local domain=$1
    local config_file

    config_file=$(grep -rl "server_name $domain" /etc/nginx/sites-enabled/*)
    
    if [[ -n $config_file ]]; then
        awk '
        /server_name/ {in_block=1}
        /}/ {if (in_block) {print; exit}}
        in_block {print}
        ' "$config_file"
    else
        echo "Domain not found: $domain"
    fi
}

# Function to display listening ports
display_ports() {
    echo -e "Protocol\tLocal Address\t\tPort\tState\tService"
    echo -e "--------\t-------------\t\t----\t-----\t-------"

    ss -tuln | awk 'NR>1 {print $1, $5, $2}' | while read -r protocol address state; do
        # Extract the port from the address
        # shellcheck disable=SC2086
        port=$(echo "$address" | awk -F':' '{print $NF}')

        # Remove interface identifiers if present
        address=${address//%*/}

        # Find the service name from /etc/services
        service=$(grep -w "$port" /etc/services | awk '{print $1}' | head -n 1)
        if [[ -z $service ]]; then
            service="unknown"
        fi

        printf "%-8s\t%-20s\t%-5s\t%-5s\t%-10s\n" "$protocol" "$address" "$port" "$state" "$service"
    done
}

# Function to display details for a specific port
display_port_details() {
    PORT=$1

    port_details=$(ss -tuln | grep ":$PORT " | awk '{print $1, $5, $2}')

    if [[ -z $port_details ]]; then
        echo "Error: Port $PORT is not being used."
        return
    fi

    echo -e "Details for Port: $PORT\n"
    echo -e "Protocol\tLocal Address\t\tState\tService"
    echo -e "--------\t-------------\t\t-----\t-------"

    echo "$port_details" | while read -r protocol address state; do
        # Extract the port from the address
        port=$(echo "$address" | awk -F':' '{print $NF}')

        # Remove interface identifiers if present
        address=${address//%*/}

        # Find the service name from /etc/services
        service=$(grep -w "$port" /etc/services | awk '{print $1}' | head -n 1)
        if [[ -z $service ]]; then
            service="unknown"
        fi

        printf "%-8s\t%-20s\t%-5s\t%-10s\n" "$protocol" "$address" "$state" "$service"
    done
}

# Function to check system activity within a date range
activity_check() {
    local start_date="$1"
    local end_date="$2"

    if [ -z "$end_date" ]; then
        echo "Displaying system information for $start_date"
        journalctl --since "$start_date 00:00:00" --until "$start_date 23:59:59" | less
    else
        echo "Displaying system information from $start_date to $end_date"
        journalctl --since "$start_date 00:00:00" --until "$end_date 23:59:59" | less
    fi
}

# Function to display log-in time
log_in_time() {
    last_log_output=$(lastlog -u "$username" 2>/dev/null | tail -n 1)
    if [[ $last_log_output == *"Never logged in"* ]]; then
        last_login="Never logged in"
    else
        last_login=$(echo "$last_log_output" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//;s/ +0000//')
    fi
}

# Function to list users or show details for a specific user
list_users() {
    # Header
    echo -e "Username\tLast Login"
    echo -e "--------\t----------"

    # Get user list and last login details
    while IFS=: read -r username _ _ uid _ _ _; do
        if [ "$uid" -ge 1000 ] && [ "$uid" != 65534 ]; then
            log_in_time
            printf "%-15s %s\n" "$username" "$last_login"
        fi
    done < /etc/passwd
}

# Function to show details for a specific user
user_details() {
    USER=$1
    # Extract user info from /etc/passwd
    user_info=$(getent passwd "$USER")
    if [ -z "$user_info" ]; then
        echo "Error: User '$USER' does not exist."
        return
    fi
    IFS=: read -r username _ uid gid _ home shell <<< "$user_info"

    # Extract group names
    groups=$(id -nG "$USER" | tr ' ' ',')

    # Get account creation date based on home directory creation time
    if [ -d "$home" ]; then
        account_created=$(stat -c %W "$home" 2>/dev/null)
        if [ "$account_created" -eq 0 ]; then
            account_created=$(stat -c %y "$home" 2>/dev/null)
        else
            account_created=$(date -d @"$account_created" '+%a %b %d %H:%M:%S %Y')
        fi
    else
        account_created="N/A"
    fi

    # Display user details in a column format
    printf "%-16s: %s\n" "Username" "$username"
    printf "%-16s: %s\n" "User ID (UID)" "$uid"
    printf "%-16s: %s\n" "Group ID (GID)" "$gid"
    printf "%-16s: %s\n" "Groups" "$groups"
    printf "%-16s: %s\n" "Home Directory" "$home"
    printf "%-16s: %s\n" "Shell" "$shell"
    printf "%-16s: %s\n" "Account Created" "$account_created"

    # Display last login info
    last_log_output=$(lastlog -u "$username" 2>/dev/null | tail -n 1)
    log_in_time
    echo -e "\nLast Login Information: $last_login"
}

# Function to show help message
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
