# Final Report on MyWhoosh2Garmin Adaptation for Windows

I have completely overhauled the monitoring system for Windows, adding support for the Microsoft Store (UWP) version. Below is a detailed breakdown of the changes.

## 1. Windows Adaptation (PowerShell)

### Initialization and Path Discovery

Previously, the script searched for `/Applications`. Now it can locate both regular versions and UWP.

```powershell
# Searching for UWP version
$uwpPackage = Get-AppxPackage -Name "MyWhooshTechnologyService.MyWhoosh"
if ($uwpPackage) {
    $pfn = $uwpPackage.PackageFamilyName
    $appId = (Get-AppxPackageManifest $uwpPackage).Package.Applications.Application | Where-Object { $_.Id -eq "MYWHOOSH" } | Select-Object -ExpandProperty Id
    # Result: MyWhooshTechnologyService.MyWhoosh_eps1123pz0kt0!MYWHOOSH
}
```

### Launch and Monitoring

Fixed the "Documents instead of game" and "premature termination" issues.

```powershell
# Launching a specific ID (AUMID)
Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder\$aumid"

# Waiting for the process to start (up to 30 sec)
while ($timeout -gt 0) {
    if (Get-Process -Name "*MyWhoosh*" -ErrorAction SilentlyContinue) { break }
}

# Waiting for closure
while (Get-Process -Name "*MyWhoosh*" -ErrorAction SilentlyContinue) { Start-Sleep -Seconds 5 }
```

## 2. Python Logic (myWhoosh2Garmin.py)

### Sync via Config

PowerShell passes the discovered data to `mywhoosh_config.json` so that Python doesn't have to search for it again.

```python
# Reading the global configuration
with open('mywhoosh_config.json', 'r') as f:
    config = json.load(f)
    uwp_path = config.get("mywhooshPath") # That same PackageFamilyName
```

### Dynamic Dependency Installation

Removed `installed_packages.json`. Now checking happens in real time.

```python
# Checking for library presence
spec = importlib.util.find_spec("garth")
if spec is None:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "garth"])
```

### Searching for FIT files in UWP

Fixed paths for deep Windows Store folders.

```python
# Path inside the UWP package
target_path = (
    directory # C:\Users\...\Packages\MyWhoosh...
    / "LocalCache" # or LocalState
    / "Local"
    / "MyWhoosh"
    / "Content"
    / "Data"
)
```

## 3. Work Summary

1.  **Reliability**: The script doesn't crash if libraries or folders are missing.
2.  **Accuracy**: Specifically the game is launched, not auxiliary software.
3.  **Automation**: The full cycle "Launch -> Wait -> Process -> Garmin" is now seamless.

## 4. Duplicate Control

The main script **myWhoosh2Garmin.py** now includes a smart check.

It uses "fingerprints" (MD5 hashes) of files to determine uniqueness. The script maintains a local list `processed_activities.json` and exits immediately if such a workout has already been sent, even if it has the same filename.

## 5. How to Pin to the Taskbar

Since Windows doesn't allow pinning a `.ps1` file directly, I created a helper script to create the correct shortcut.

1. Run in terminal: `.\CreateShortcut.ps1`.
2. A shortcut named **MyWhoosh Monitor** will appear on the desktop.
3. Right-click it and select **"Pin to taskbar"**.
   - _Note:_ In Windows 11, you might need to click "Show more options" first.
4. Now you can launch monitoring directly from the taskbar!
