#!/bin/bash

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

