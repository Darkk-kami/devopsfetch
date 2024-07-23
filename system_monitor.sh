#!/bin/bash

LOG_FILE="/var/log/system_monitor.log"
LOG_DIR="/var/log"

mkdir -p "$LOG_DIR"

# Function to log a header
log_header() {
    {
     echo "----------------------------------------"
     echo "$(date): Running system checks"
     echo "----------------------------------------"
    } >> "$LOG_FILE"
}

# Function to log user login information
log_user_info() {
    {
    echo -e "Username\tLast Login"
    echo -e "--------\t----------"

    # Get user list and last login details
    while IFS=: read -r username _ _ uid _ _ _; do
        if [ "$uid" -ge 1000 ] && [ "$uid" != 65534 ]; then
         last_log_output=$(lastlog -u "$username" 2>/dev/null | tail -n 1)
            if [[ $last_log_output == *"Never logged in"* ]]; then
                last_login="Never logged in"
            else
                last_login=$(echo "$last_log_output" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//;s/ +0000//')
            fi
            printf "%-15s %s\n" "$username" "$last_login"
        fi
    done < /etc/passwd
    } >> "$LOG_FILE"
}

# Function to log listening ports
log_ports_info() {
    {
        echo -e "\n\nListening ports:"
        echo -e "Protocol\tLocal Address\t\tPort\tState\tService"
        echo -e "--------\t-------------\t\t----\t-----\t-------"
        ss -tuln | awk 'NR>1 {print $1, $5, $2}' | while read -r protocol address state; do
            # Extract the port from the address
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
        echo "----------------------------------------"
        echo
    } >> "$LOG_FILE"
}

# Function to log Docker container information
log_docker_info() {
    {
        echo "Docker containers and images:"
        echo "----------------------------------------"
        docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}\t{{.Ports}}\t{{.Names}}"
        docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}"
        echo "----------------------------------------"
        echo
    } >> "$LOG_FILE"
}

# Function to log Nginx configured domains
log_nginx_info() {
    {
        echo "Nginx configured domains:"
        echo -e "DOMAIN\t\t\tPROXY_PASS_URL"
        grep -r "server_name" /etc/nginx/sites-enabled/ | while read -r line; do
            conf=$(echo "$line" | cut -d':' -f1)
            domain=$(echo "$line" | awk '{print $2}' | sed 's/;//')
            proxy_pass=$(grep -A 10 "server_name $domain" "$conf" | grep "proxy_pass" | awk '{print $2}' | sed 's/;//')
            echo -e "$domain\t\t$proxy_pass"
        done | column -t
        echo "----------------------------------------"
        echo
    } >> "$LOG_FILE"
}

# Function to log the completion of checks
log_footer() {
    {
        echo "$(date): Check completed."
        echo "========================================"
        echo "========================================"
    } >> "$LOG_FILE"
}

# Main monitoring function
monitor_system() {
    while true; do
        log_header
        log_user_info
        log_ports_info
        log_docker_info
        log_nginx_info
        log_footer

        sleep 600
    done
}

monitor_system
