#!/bin/bash

# --- macOS Shortcut Creator for myWhoosh2Garmin ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

APP_NAME="myWhooshSync"
APP_PATH="$SCRIPT_DIR/$APP_NAME.app"

echo "Creating macOS Application: $APP_NAME..."

# Create the AppleScript source with explicit logging and permanent loop
cat <<EOF > myscript.applescript
property targetAppId : "com.whoosh.whooshgame"
property appRunning : false
property logFile : "/tmp/myWhooshSync.log"

on run
	do shell script "echo '--- App Started " & (current date as string) & " ---' >> " & logFile
	repeat
		try
			set isRunning to false
			tell application "System Events"
				if (exists (every process whose bundle identifier is targetAppId)) then
					set isRunning to true
				end if
			end tell
			
			if isRunning then
				if not appRunning then
					set appRunning to true
					do shell script "echo 'MyWhoosh detected, launching monitor...' >> " & logFile
					performAction()
				end if
			else
				if appRunning then
					set appRunning to false
					do shell script "echo 'MyWhoosh stopped.' >> " & logFile
				end if
			end if
		on error errMsg
			do shell script "echo 'Loop Error: " & errMsg & "' >> " & logFile
		end try
		delay 30
	end repeat
end run

on performAction()
	try
		set scriptPath to POSIX path of ((path to me as text) & "Contents:Resources:macOSMonitor.sh")
		do shell script "bash " & quoted form of scriptPath & " >> " & logFile & " 2>&1 &"
	on error errMsg
		do shell script "echo 'PerformAction Error: " & errMsg & "' >> " & logFile
	end try
end performAction

on quit
	do shell script "echo '--- App Quitting ---' >> " & logFile
	continue quit
end quit
EOF

# Compile to an Application
osacompile -o "$APP_NAME.app" myscript.applescript

# 3. Set LSUIElement to 1 to run as a background agent (no Dock icon)
defaults write "$SCRIPT_DIR/$APP_NAME.app/Contents/Info.plist" LSUIElement -string "1"
# Also set LSBackgroundOnly if preferred, but LSUIElement is usually enough for a tray-like app
# defaults write "$SCRIPT_DIR/$APP_NAME.app/Contents/Info.plist" LSBackgroundOnly -bool true

# Small hack to make it stay open and run in background properly
# 1. Ensure the app stays open (info.plist check)
# osacompile with -o .app usually handles the basic bundle

# 2. Copy the monitor script into the bundle so it's portable
mkdir -p "$APP_NAME.app/Contents/Resources"
cp "$SCRIPT_DIR/macOSMonitor.sh" "$APP_NAME.app/Contents/Resources/"
cp "$SCRIPT_DIR/myWhoosh2Garmin.py" "$APP_NAME.app/Contents/Resources/"
cp "$SCRIPT_DIR/pyproject.toml" "$APP_NAME.app/Contents/Resources/"

# 4. Make utilities executable
chmod +x "$SCRIPT_DIR/Login.command"
chmod +x "$SCRIPT_DIR/macOSMonitor.sh"

rm myscript.applescript

echo "------------------------------------------------"
echo "✅ SUCCESS! macOS Setup Complete"
echo "------------------------------------------------"
echo ""
echo "Instructions for 'Regular Users':"
echo "1. Double-click 'Login.command' to log in to Garmin (One-time only)."
echo "2. Drag 'myWhooshSync.app' to your Applications folder."
echo "3. Open 'System Settings' -> 'Full Disk Access' and enable 'myWhooshSync.app'."
echo "4. Open 'myWhooshSync.app' once, then just start riding!"
echo ""
echo "For more details, see: QUICK_START_MAC.md"
echo "------------------------------------------------"
