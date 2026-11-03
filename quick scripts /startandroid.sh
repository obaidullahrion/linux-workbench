#!/bin/bash

# --- Waydroid networking setup ---
echo "Checking firewall status for Waydroid..."

# Check if FORWARD is allowed
FORWARD_STATUS=$(sudo ufw status | grep "Forwarding: on")
if [ -z "$FORWARD_STATUS" ]; then
    echo "Enabling packet forwarding..."
    sudo ufw default allow FORWARD
else
    echo "Packet forwarding already allowed."
fi

# Check if DNS (53) is allowed
DNS_STATUS=$(sudo ufw status | grep "53")
if [ -z "$DNS_STATUS" ]; then
    echo "Allowing DNS (port 53)..."
    sudo ufw allow 53
else
    echo "DNS (port 53) already allowed."
fi

# Check if DHCP (67) is allowed
DHCP_STATUS=$(sudo ufw status | grep "67")
if [ -z "$DHCP_STATUS" ]; then
    echo "Allowing DHCP (port 67)..."
    sudo ufw allow 67
else
    echo "DHCP (port 67) already allowed."
fi

# --- Start Weston ---
export WAYLAND_DISPLAY=mysocket
echo "Starting Weston..."
weston --socket=$WAYLAND_DISPLAY --backend=x11-backend.so --width=920 --height=580 &
sleep 2

# --- Start Waydroid UI ---
echo "Starting Waydroid..."
waydroid show-full-ui &
