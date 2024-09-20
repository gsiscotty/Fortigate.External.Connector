#!/bin/bash

#########################################
# Created by: Konrad von Burg           #
# Date: 2024-09-20                      #
# Description: This Script converts API #
# IP List to .txt file list from github #
# FortiGate Firewall can import this    #
# via FortiGate External Connector      #
#                                       #
# Version: 0.5                          #
#                                       #
# Note:                                 #
#                                       #
#                                       #
#########################################

# Directory where the IP list will be saved (you can change this path)
OUTPUT_DIR="/volume1/web/github-meta/"
OUTPUT_FILE="github_actions_ips.txt"

# URL to GitHub Meta API
GITHUB_META_API="https://api.github.com/meta"

# Log file for error handling
LOG_FILE="/volume2/System_Logs/github_ip_updater.log"

# Function to log messages
log_message() {
    echo "$(date): $1" >> $LOG_FILE
}

# Fetch GitHub IP ranges from the Meta API
log_message "Starting GitHub IP range update."

# Fetch the data from GitHub Meta API
response=$(curl -s $GITHUB_META_API)

if [[ $? -ne 0 ]]; then
    log_message "Failed to fetch data from GitHub API."
    exit 1
fi

# Extract the 'actions' IP ranges from the JSON response using grep and sed
# We'll now try a simpler approach by extracting anything between "actions" and the next key
actions_ips=$(echo "$response" | sed -n '/"actions": \[/,/\]/p' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+')

if [[ -z "$actions_ips" ]]; then
    log_message "No IP addresses found for GitHub Actions."
    exit 1
fi

# Save the IP ranges to a file, ensuring the directory exists
mkdir -p "$OUTPUT_DIR"
echo "$actions_ips" > "$OUTPUT_DIR/$OUTPUT_FILE"

if [[ $? -eq 0 ]]; then
    log_message "GitHub Actions IP ranges successfully updated."
    echo "GitHub Actions IP ranges have been written to $OUTPUT_DIR/$OUTPUT_FILE"
else
    log_message "Failed to write IP ranges to $OUTPUT_DIR/$OUTPUT_FILE."
    exit 1
fi

exit 0