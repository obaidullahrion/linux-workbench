#!/bin/bash

# Stop Waydroid container
echo "Stopping Waydroid container..."
sudo systemctl stop waydroid-container

# Kill any running Waydroid UI
echo "Killing Waydroid UI..."
pkill -f "waydroid show-full-ui"

# Kill Weston session running on our socket
echo "Killing Weston..."
pkill -f "weston --socket=mysocket"

# --- Revert firewall rules ---
echo "Reverting Waydroid firewall rules..."

# Check if rules exist before deleting
if sudo ufw status | grep -q "Forwarding: on"; then
    echo "Resetting packet forwarding to default..."
    sudo ufw default deny FORWARD
fi

if sudo ufw status | grep -q "53"; then
    echo "Removing DNS rule..."
    sudo ufw delete allow 53
fi

if sudo ufw status | grep -q "67"; then
    echo "Removing DHCP rule..."
    sudo ufw delete allow 67
fi

echo "Android environment stopped."
