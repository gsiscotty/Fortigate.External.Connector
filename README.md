**GitHub Actions IP Fetcher for FortiGate External Connector**

This script is designed to fetch the current **GitHub Actions** IP ranges from the [GitHub Meta API](https://api.github.com/meta), save them as a text file, and make the file accessible for use with FortiGate’s **External Connectors**. The FortiGate firewall can then dynamically update its rules based on the latest GitHub IP ranges.

### **Script Overview**

•	The script queries the **GitHub Meta API** to retrieve IP ranges related to **GitHub Actions**.

•	It extracts these IP ranges and saves them to a .txt file in a specified directory on a Synology NAS.

•	The saved file can be accessed via a web server running on the NAS (e.g., **Web Station**), making it available for FortiGate’s External Connectors feature.

•	A logging mechanism is included to record the process and any errors that occur during execution.

### **Requirements**

•	Synology NAS with SSH access enabled.

•	Web Station installed to serve the IP file over HTTP.

•	The script uses standard Linux utilities (curl, grep, sed, awk), so no additional dependencies like jq are needed.

### **Usage**

1.	**SSH into Synology NAS**: Log in via SSH to create and run the script.

2.	**Create the Script**: Copy the following script and save it as github_ip_updater.sh:

```bash
#!/bin/bash

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
```

### 3.	**Test the Script**:

Run the script manually to ensure it works:

```bash
sh /volume1/web/github-meta/github_ip_updater.sh
```

### 4.	**Automate the Script** (Optional):

Use Synology’s **Task Scheduler** to run the script periodically (e.g., daily) to keep the IP list updated.

### 5.	**Access the IP File**:

The IP ranges will be saved to a .txt file in /volume1/web/github-meta/github_actions_ips.txt, which can be accessed via HTTP (e.g., http://<Synology_IP>/github-meta/github_actions_ips.txt).

### 6.	**Use in FortiGate**:

Configure your FortiGate External Connector to dynamically pull the IP ranges using the URL of the hosted file.

### **Logs**

Logs for the script’s execution can be found in /volume2/System_Logs/github_ip_updater.log. This log includes timestamps for each update and any errors encountered.
