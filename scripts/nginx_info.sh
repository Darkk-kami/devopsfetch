#!/bin/bash

# Function to display all Nginx domains and their ports
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
