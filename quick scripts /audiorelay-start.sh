#!/bin/bash

# --- Firewall Rules ---
echo "Adding firewall rules for AudioRelay..."
sudo ufw allow 59100/tcp
sudo ufw allow 59100/udp
sudo ufw reload

# --- Create Virtual Sink ---
echo "Creating virtual audio sink..."
pactl load-module module-null-sink \
    sink_name=audiorelay-virtual-mic-sink \
    sink_properties=device.description="Virtual-Mic-Sink"

# --- Create Remapped Source for Communication Apps ---
echo "Creating virtual mic source..."
pactl load-module module-remap-source \
    master=audiorelay-virtual-mic-sink.monitor \
    source_name=audiorelay-virtual-mic-sink \
    source_properties=device.description="Virtual-Mic"

echo "Setup complete! Virtual mic is ready for use."
