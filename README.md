# devopsfetch

## Overview
A tool aimed at collecting and displaying system information, such as active ports, user logins, Nginx configurations, and Docker images.
## Prequisites
* An Ubuntu Machine
* Docker installed
* Sudo Privileges

## Installation
1. If You do not already have docker installed follow the link below on your preferred way of installing docker.


  [Docker installation guide](https://docs.docker.com/engine/install/)

3. Clone this repository
4. Run the installation script with sudo priviledges
```
cd devopsfetch
chmod +x install.sh
sudo ./install.sh
```
This script:
* Updates all package lists
* Makes sure the necessary dependencies are installed
* Installs and enables the Nginx service
* Creates a `devopsfetch.service` that automatically logs the devopsfetch information to a `/var/log/system_monitor.log` file every 10 minutes. The log file is rotated and managed automatically.


  confirm this service is running with the following command
  ```
  sudo systemctl status devopsfetch.service
  ```
  view the logs
  ````
  sudo cat /var/log/system_monitor.log
  ````

### Options
These are the available commands that come with this tool:
```
-p, --port [PORT_NUMBER] - Display all active ports and services or detailed information about a specific port.
    Example:
    devopsfetch --port                # Show all listening ports
    devopsfetch --port 53             # Show detailed information about port 53

-d, --docker [CONTAINER_NAME] - List all Docker images and containers or provide detailed information about a specific container.
    Example:
    devopsfetch --docker              # List all Docker images and containers
    devopsfetch --docker my_container # Show detailed information about the container named 'my_container'

-n, --nginx [DOMAIN] - Display all Nginx domains and their ports or detailed configuration information for a specific domain.
    Example:
    devopsfetch --nginx               # Display all Nginx domains and their ports
    devopsfetch --nginx mydomain.com  # Show detailed configuration information for the domain 'mydomain.com'

-u, --users [USERNAME] - List all users and their last login times or provide detailed information about a specific user.
    Example:
    devopsfetch --users               # List all users and their last login times
    devopsfetch --users john          # Show detailed information about the user 'john'

-t, --time [START_DATE] [END_DATE] - Display activities within a specified time range.
    Example:
    devopsfetch --time 2024-07-01  # Display activities that happened on July 1, 2024
    devopsfetch --time 2024-07-01 2024-07-10  # Display activities between July 1, 2024, and July 10, 2024

-h, --help - Display this help message.
    Example:
    devopsfetch --help                # Display this help message
```

