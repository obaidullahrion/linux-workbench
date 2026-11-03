#!/bin/bash

# ===============================================
# Interactive CPU governor selector for all cores
# Shows current CPU status first
# Arrow-key selection menu to choose new governor
# Applies governor per core individually
# ===============================================

GOVERNORS=("performance" "ondemand" "schedutil")

# Show current status per core
echo "Current CPU governors:"
for cpu in 0 1 2 3; do
    GOV=$(cpufreq-info -c $cpu | grep "The governor" | awk '{print $3}')
    echo "CPU $cpu: $GOV"
done

echo ""
echo "Select CPU governor to apply (use ↑/↓ and Enter):"
sleep 1

# Initialize selected index
SEL_INDEX=0

# Function to draw menu
draw_menu() {
    for i in "${!GOVERNORS[@]}"; do
        if [ $i -eq $1 ]; then
            echo " -> ${GOVERNORS[$i]}"
        else
            echo "    ${GOVERNORS[$i]}"
        fi
    done
}

# Arrow-key menu
while true; do
    clear
    echo "Current CPU governors:"
    for cpu in 0 1 2 3; do
        GOV=$(cpufreq-info -c $cpu | grep "The governor" | awk '{print $3}')
        echo "CPU $cpu: $GOV"
    done
    echo ""
    echo "Select CPU governor to apply (use ↑/↓ and Enter):"
    draw_menu $SEL_INDEX

    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        if [[ $key == "[A" ]]; then
            ((SEL_INDEX--))
            if [ $SEL_INDEX -lt 0 ]; then SEL_INDEX=$((${#GOVERNORS[@]}-1)); fi
        elif [[ $key == "[B" ]]; then
            ((SEL_INDEX++))
            if [ $SEL_INDEX -ge ${#GOVERNORS[@]} ]; then SEL_INDEX=0; fi
        fi
    elif [[ $key == "" ]]; then
        CHOSEN=${GOVERNORS[$SEL_INDEX]}
        echo ""
        echo "Applying '$CHOSEN' governor to all cores..."
        for cpu in 0 1 2 3; do
            sudo cpufreq-set -c $cpu -g $CHOSEN
        done
        echo "Done!"
        break
    fi
done

# Show updated governor per core
echo ""
echo "Updated CPU governors:"
for cpu in 0 1 2 3; do
    GOV=$(cpufreq-info -c $cpu | grep "The governor" | awk '{print $3}')
    echo "CPU $cpu: $GOV"
done

