#!/bin/bash

log_in_time() {
    last_log_output=$(lastlog -u "$username" 2>/dev/null | tail -n 1)
    if [[ $last_log_output == *"Never logged in"* ]]; then
        last_login="Never logged in"
    else
        last_login=$(echo "$last_log_output" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//;s/ +0000//')
    fi
}

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