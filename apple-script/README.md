<h1>Apple Script to automate Garmin Upload</h1>
<p>The app will launch the sync engine in <strong>Monitor Mode</strong>. It will automatically detect new workouts while you ride and upload them immediately without needing to restart the script or the game.</p>
<h2>🛠️ Installation Steps:</h2>
<ol>
  <li>Download MyWhoosh2Garmin-AS.scpt to your filesystem to a folder of your choosing.</li>
  <li>Go to the folder where you downloaded the script via Mac Finder.</li>
  <li>Open the script in the Apple Script Editor and set the property <code>pythonScriptPath</code> to the location where you downloaded the 
  <code>myWhoosh2Garmin.py</code> script.</li>
  
```
property targetApp : "MyWhoosh Indoor Cycling App"
property pythonScriptPath : "/path/to/myWhoosh2Garmin.py"
property appRunning : false

on idle
if application targetApp is running then
if not appRunning then
set appRunning to true
-- Start the monitor mode
performAction()
end if
else
set appRunning to false
end if
return 60 -- Check every 60 seconds
end idle

on performAction()
-- Launch the Python script via Poetry in monitor mode
-- It will stay active until MyWhoosh is closed
do shell script "poetry run python3 " & quoted form of pythonScriptPath & " --monitor > /dev/null 2>&1 &"
end performAction

on quit
continue quit
end quit

```

  <li>After changing the property file, export the file as an app.</li>
  <li>Please select File Format <code>Application</code>.</li>
  <li>Please select <code>Stay open after run handler</code> an export option.</li>
  <li>Store the app at a location of your choice.
	<img width="1100" alt="Xnip2024-12-30_22-16-55" src="https://github.com/user-attachments/assets/54fa1ab0-2ed3-46a0-808e-1420c29c7736" />
  </li>
  <li>Before running the script, you need to grant the app full access to your hard drive. Otherwise, you will be prompted each time to allow access when the myWhoosh2Garmin is executed. Please search the web for a guide, given it slightly depends on your Mac OS version. See screenshot of my setup (I gave my App the My Whoosh icon): <img width="827" alt="Xnip2024-12-30_22-28-22" src="https://github.com/user-attachments/assets/c4004375-36ef-42c1-936f-99eba47639c6" />
  </li>
  <li>Now you can run the App and start riding on My Whoosh. All workouts will be synced in real-time.</li>
</ol>
```
