<h1>macOS Monitor: one-click setup</h1>

The easiest way to set up the sync engine on macOS is by using the automated shortcut creator. This will generate a native `.app` that stays active in the background and watches for MyWhoosh.

## 🚀 One-Click Installation

1. Open your terminal in the project directory.
2. Run the shortcut creator:
   ```bash
   bash CreateMacShortcut.sh
   ```
3. A **myWhooshSync.app** will appear in the project folder.
4. **Drag it** to your Applications folder or Dock for easy access.

## 🛠️ Security Permissions

Before the first run, you need to grant the app permission to watch for processes and access files:

1. Open **System Settings** > **Privacy & Security**.
2. Go to **Full Disk Access**.
3. Click the **[+]** button and add `myWhooshSync.app`.
4. Run the app once. It will stay open (visible in the Dock/Menu Bar) and wait for you to start riding!

---

### Manual Reference (AppleScript)

If you wish to modify the behavior, the app is built from this logic:

```applescript
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
	-- Launches macOSMonitor.sh inside the app bundle
	set scriptPath to POSIX path of ((path to me as text) & "Contents:Resources:macOSMonitor.sh")
	do shell script "bash " & quoted form of scriptPath & " > /dev/null 2>&1 &"
end performAction
```
