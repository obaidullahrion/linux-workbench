#!/bin/bash

# --- Remove Firewall Rules ---
echo "Removing firewall rules..."
sudo ufw delete allow 59100/tcp
sudo ufw delete allow 59100/udp
sudo ufw reload

# --- Unload PulseAudio / PipeWire Modules ---

# Find module IDs by name
sink_module=$(pactl list short modules | grep 'module-null-sink.*audiorelay-virtual-mic-sink' | awk '{print $1}')
remap_module=$(pactl list short modules | grep 'module-remap-source.*audiorelay-virtual-mic-sink' | awk '{print $1}')

# Unload if found
if [ -n "$remap_module" ]; then
    echo "Unloading remap source module..."
    pactl unload-module "$remap_module"
fi

if [ -n "$sink_module" ]; then
    echo "Unloading null sink module..."
    pactl unload-module "$sink_module"
fi

echo "Cleanup complete!"
