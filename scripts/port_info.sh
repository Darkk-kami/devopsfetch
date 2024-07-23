#!/bin/bash

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