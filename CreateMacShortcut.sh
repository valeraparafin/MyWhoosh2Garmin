#!/bin/bash

# --- macOS Shortcut Creator for myWhoosh2Garmin ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

APP_NAME="myWhooshSync"
APP_PATH="$SCRIPT_DIR/$APP_NAME.app"

echo "Creating macOS Application: $APP_NAME..."

# Create the AppleScript source
cat <<EOF > myscript.applescript
property targetApp : "MyWhoosh Indoor Cycling App"
property appRunning : false

on idle
	if application targetApp is running then
		if not appRunning then
			set appRunning to true
			performAction()
		end if
	else
		set appRunning to false
	end if
	return 60
end idle

on performAction()
	set scriptPath to POSIX path of ((path to me as text) & "Contents:Resources:macOSMonitor.sh")
	do shell script "bash " & quoted form of scriptPath & " > /dev/null 2>&1 &"
end performAction

on quit
	continue quit
end quit
EOF

# Compile to a Stay-Open Application
osacompile -o "$APP_NAME.app" myscript.applescript

# Small hack to make it stay open and run in background properly
# 1. Ensure the app stays open (info.plist check)
# osacompile with -o .app usually handles the basic bundle

# 2. Copy the monitor script into the bundle so it's portable
mkdir -p "$APP_NAME.app/Contents/Resources"
cp "$SCRIPT_DIR/macOSMonitor.sh" "$APP_NAME.app/Contents/Resources/"
cp "$SCRIPT_DIR/myWhoosh2Garmin.py" "$APP_NAME.app/Contents/Resources/"
cp "$SCRIPT_DIR/pyproject.toml" "$APP_NAME.app/Contents/Resources/"

# Update the internal script path in the app to look inside itself
# (Already handled in the AppleScript source above using Contents:Resources)

rm myscript.applescript

echo "------------------------------------------------"
echo "Done! $APP_NAME.app has been created in:"
echo "$SCRIPT_DIR"
echo ""
echo "Instructions:"
echo "1. Drag $APP_NAME.app to your Applications folder or Dock."
echo "2. Give it 'Full Disk Access' in System Settings."
echo "3. Run it once, and it will wait for MyWhoosh to start!"
echo "------------------------------------------------"
