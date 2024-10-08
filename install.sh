#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Install necessary dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y jq net-tools nginx

# Create the /opt/devopsfetch directory
sudo mkdir -p /opt/devopsfetch

# Copy all the files to the /opt/devopsfetch directory
sudo cp -r . /opt/devopsfetch

# Create a symbolic link to make devopsfetch available system-wide
sudo ln -sf /opt/devopsfetch/devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /opt/devopsfetch/devopsfetch.sh
sudo chmod +x /opt/devopsfetch/system_monitor.sh
sudo touch /var/log/system_monitor.log
sudo chmod 666 /var/log/system_monitor.log

# Create a systemd service file for continuous monitoring
sudo tee /etc/systemd/system/devopsfetch.service > /dev/null <<EOL
[Unit]
Description=Devopsfetch System Monitor

[Service]
ExecStart=/opt/devopsfetch/system_monitor.sh
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the devopsfetch service
systemctl enable nginx
systemctl start nginx
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

echo "Devopsfetch has been installed and the monitoring service has been started."
