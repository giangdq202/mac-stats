#!/bin/bash

echo "Starting CPU Stress Test (Apple Silicon)..."
echo "Press Ctrl+C at any time to stop."
echo "------------------------------------------------"

# Get logical core count
CORES=$(sysctl -n hw.logicalcpu)
echo "Detected $CORES CPU cores. Pushing CPU load to 100%..."

# Array to store PIDs of stress processes
PIDS=()

# Run 'yes' processes in the background for each core
for i in $(seq 1 $CORES); do
    yes > /dev/null &
    PIDS+=($!)
done

# Cleanup function when user presses Ctrl+C
cleanup() {
    echo -e "\nStopping stress test and cooling down CPU..."
    kill "${PIDS[@]}" 2>/dev/null
    echo "Stopped successfully!"
    exit 0
}

# Trap SIGINT (Ctrl+C) to run cleanup
trap cleanup SIGINT

echo "Stress test is running at 100% load!"
echo "Check the MeMo menu now to see:"
echo "   - CPU (%) reaching maximum."
echo "   - P-Cores, E-Cores temperatures rising rapidly (from ~50C to 80C - 90C)."
echo "------------------------------------------------"

# Keep script alive
while true; do
    sleep 1
done
