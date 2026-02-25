<h1 align="center" id="title">myWhoosh2Garmin</h1>

<h2>🧐Features</h2>

- Finds the .fit files from your MyWhoosh installation. **(Improved: now supports Windows UWP/Store version)**
- Fix the missing power & heart rate averages.
- Removes the temperature.
- Create a backup file to a folder you select.
- Uploads the fixed .fit file to Garmin Connect.
- **New!** Smart Duplicate Detection (MD5 hashing) to prevent double uploads.

<h2>🛠️ Installation Steps:</h2>

<p>1. Download myWhoosh2Garmin.py to your filesystem to a folder or your choosing.</p>

<p>2. Go to the folder where you downloaded the script in a shell.</p>

- <b>MacOS:</b> Terminal of your choice.
- <b>Windows:</b> Start > Run > powershell

<p>3. Install `pipenv` (if not already installed):</p>

```
pip3 install pipenv
or
pip install pipenv
```

<p>4. Install dependencies in a virtual environment:</p>

```
pipenv install
```

_Note: You can also use `pip install garth fit_tool` directly._

<p>5. Activate the virtual environment:</p>

```
pipenv shell
```

<p>6. Run the script:</p>

```
python3 myWhoosh2Garmin.py
or
python myWhoosh2Garmin.py
```

<p>7. Choose your backup folder.</p>

<h3>MacOS</h3>

![image](https://github.com/user-attachments/assets/2c6c1072-bacf-4f0c-8861-78f62bf51648)

<h3>Windows</h3>

![image](https://github.com/user-attachments/assets/d1540291-4e6d-488e-9dcf-8d7b68651103)

<p>8. Enter your Garmin Connect credentials.</p>

```
2024-11-21 10:08:04,014 No existing session. Please log in.
Username: <YOUR_EMAIL>
Password:
2024-11-21 10:08:33,545 Authenticating...

2024-11-21 10:08:37,107 Successfully authenticated!
```

<p>(9. Or see below to automate the process)</p>
<h3>Windows (New & Automated)</h3>

<p>For the best experience on Windows, use new automated monitor:</p>

1. Run `.\CreateShortcut.ps1` in PowerShell.
2. A **MyWhoosh Monitor** shortcut will appear on your desktop with the game icon.
3. Pin this shortcut to your Taskbar.
4. Clicking it will launch the game, wait for you to finish, and automatically upload your ride.

<p>10. Enter your Garmin Connect credentials on first run.</p>

<h2>ℹ️ Automation tips</h2>

What if you want to automate the whole process:

<h3>MacOS</h3>

PowerShell on MacOS (Verified & works) **NOT TESTED ON MACOS YET**

You need Powershell

```shell
brew install powershell/tap/powershell
```

```powershell
# Define the JSON config file path
$configFile = "$PSScriptRoot\mywhoosh_config.json"
$myWhooshApp = "myWhoosh Indoor Cycling App.app"

# Check if the JSON file exists and read the stored path
if (Test-Path $configFile) {
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    $mywhooshPath = $config.path
} else {
    $mywhooshPath = $null
}

# Validate the stored path
if (-not $mywhooshPath -or -not (Test-Path $mywhooshPath)) {
    Write-Host "Searching for $myWhooshApp"
    $mywhooshPath = Get-ChildItem -Path "/Applications" -Filter $myWhooshApp -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if (-not $mywhooshPath) {
        Write-Host " not found!"
        exit 1
    }

    $mywhooshPath = $mywhooshPath.FullName

    # Store the path in the JSON file
    $config = @{ path = $mywhooshPath }
    $config | ConvertTo-Json | Set-Content -Path $configFile
}

Write-Host "Found $myWhooshApp at $mywhooshPath"

Start-Process -FilePath $mywhooshPath

# Wait for the application to finish
Write-Host "Waiting for $myWhooshApp to finish..."
while ($process = ps -ax | grep -i $myWhooshApp | grep -v "grep") {
    Write-Output $process
    Start-Sleep -Seconds 5
}

# Run the Python script
Write-Host "$myWhooshApp has finished, running Python script..."
python3 "<PATH_WHERE_YOUR_SCRIPT_IS_LOCATED>/MyWhoosh2Garmin/myWhoosh2Garmin.py"
```

AppleScript (need to test further)

```applescript
TODO: needs more work
```

<h3>Windows</h3>

Windows .ps1 (PowerShell) file (Tested on Windows)

```powershell
# Define the JSON config file path
$configFile = "$PSScriptRoot\mywhoosh_config.json"
$myWhooshApp = "MyWhoosh"

# Check if the JSON file exists and read the stored path
if (Test-Path $configFile) {
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    $mywhooshPath = $config.path
    $isUWP = $config.isUWP
} else {
    $mywhooshPath = $null
    $isUWP = $false
}

# Validate the stored path or package
if (-not $mywhooshPath -or (-not $isUWP -and -not (Test-Path $mywhooshPath))) {
    Write-Host "Searching for $myWhooshApp..."

    # 1. Check for UWP (Windows Store) version
    $uwpPackage = Get-AppxPackage -Name "MyWhooshTechnologyService.MyWhoosh" -ErrorAction SilentlyContinue
    if ($uwpPackage) {
        # PackageFamilyName is used for folder paths
        $pfn = $uwpPackage.PackageFamilyName
        # Find the specific Application ID for the game (not the prereq setup)
        $manifest = Get-AppxPackageManifest $uwpPackage
        $appId = $manifest.Package.Applications.Application | Where-Object { $_.Id -eq "MYWHOOSH" } | Select-Object -ExpandProperty Id
        if (-not $appId) {
            # Fallback to the first one if "MYWHOOSH" isn't found
            $appId = $manifest.Package.Applications.Application[0].Id
        }
        Write-Host "Found Windows Store version: $pfn!$appId"
        # Store only the PFN in path for consistency with the Python script folder discovery
        $mywhooshPath = $pfn
        $isUWP = $true
    } else {



        # 2. Check common Windows installation paths
        $searchPaths = @(
            "$env:ProgramFiles\MyWhoosh",
            "$env:ProgramFiles(x86)\MyWhoosh",
            "$env:LocalAppData\Programs\MyWhoosh",
            "$env:ProgramFiles\MyWhoosh HD",
            "$env:ProgramFiles(x86)\MyWhoosh HD",
            "$env:LocalAppData\Programs\MyWhoosh HD"
        )

        foreach ($path in $searchPaths) {
            if (Test-Path $path) {
                $file = Get-ChildItem -Path $path -Filter "$myWhooshApp.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($file) {
                    $mywhooshPath = $file.FullName
                    $isUWP = $false
                    break
                }
            }
        }
    }

    if (-not $mywhooshPath) {
        Write-Host "Searching broadly (this may take a while)..."
        $file = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "$myWhooshApp.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($file) {
            $mywhooshPath = $file.FullName
            $isUWP = $false
        }
    }

    if (-not $mywhooshPath) {
        Write-Host " $myWhooshApp not found! Please set the path manually in $configFile"
        exit 1
    }

    # Store the path in the JSON file
    $config = @{ path = $mywhooshPath; isUWP = $isUWP }
    $config | ConvertTo-Json | Set-Content -Path $configFile
}

if ($isUWP) {
    Write-Host "Starting $myWhooshApp (Windows Store version)..."
    # Reconstruct AUMID to launch the app
    $uwpPackage = Get-AppxPackage -Name "MyWhooshTechnologyService.MyWhoosh" -ErrorAction SilentlyContinue
    $manifest = Get-AppxPackageManifest $uwpPackage
    $appId = $manifest.Package.Applications.Application | Where-Object { $_.Id -eq "MYWHOOSH" } | Select-Object -ExpandProperty Id
    if (-not $appId) { $appId = $manifest.Package.Applications.Application[0].Id }
    $aumid = "$mywhooshPath!$appId"
    Write-Host "Launching AUMID: $aumid"
    Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\$aumid"
} else {


    Write-Host "Found $myWhooshApp at $mywhooshPath"
    Start-Process -FilePath $mywhooshPath
}

# Wait for the application to start
Write-Host "Waiting for $myWhooshApp to start..."
$timeout = 30 # 30 seconds timeout to start
$started = $false
while ($timeout -gt 0) {
    if (Get-Process -Name "*MyWhoosh*" -ErrorAction SilentlyContinue) {
        $started = $true
        break
    }
    Start-Sleep -Seconds 1
    $timeout--
}

if (-not $started) {
    Write-Host "Warning: $myWhooshApp did not seem to start within 30 seconds."
} else {
    Write-Host "$myWhooshApp is running. Waiting for it to finish..."
    # Wait for it to finish
    while ($process = Get-Process -Name "*MyWhoosh*" -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 5
    }
}


# Run the Python script
Write-Host "$myWhooshApp has finished, running Python script..."

# Check if python or python3 is available
$pythonCmd = "python"
if (-not (Get-Command $pythonCmd -ErrorAction SilentlyContinue)) {
    $pythonCmd = "python3"
}

& $pythonCmd myWhoosh2Garmin.py

Write-Host "`nDone! Press any key to close this window..." -ForegroundColor Gray

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")


```

<h2>💻 Built with</h2>

Technologies used in the project:

- Neovim
- <a href="https://github.com/matin/garth">Garth</a>
- tKinter
- <a href="https://bitbucket.org/stagescycling/fit_tool/src/main/">Fit_tool</a>
- **New:** MD5 Fingerprinting for reliable duplicate detection.
