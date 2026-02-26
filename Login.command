#!/bin/bash
# --- macOS Garmin Login Utility ---
# Double-click this file in Finder to log in to Garmin.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo "------------------------------------------------"
echo "   Garmin Login for myWhoosh2Garmin"
echo "------------------------------------------------"
echo ""

# Run the monitor script in foreground to allow user input
bash macOSMonitor.sh

echo ""
echo "------------------------------------------------"
echo "Done! You can close this window now."
echo "------------------------------------------------"
read -n 1 -s -r -p "Press any key to exit..."
echo ""
