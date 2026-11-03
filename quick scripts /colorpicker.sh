#!/bin/bash
# Launch gpick pick mode in the background
gpick -p &
pid=$!           # capture PID of this specific gpick
# Give 10 seconds to pick
sleep 60
# Kill only this PID
kill $pid

