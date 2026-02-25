# Windows Support: myWhoosh2Garmin

This guide covers Windows-specific implementation details, primarily focusing on the Microsoft Store (UWP) version and automation.

## 1. Windows Store (UWP) Compatibility

The monitor is fully compatible with the UWP version of MyWhoosh. It handles complex path discovery and launch process automatically.

### Path Discovery

The scripts use the `Get-AppxPackage` command to locate the game folder and Application ID (AUMID).

```powershell
$uwpPackage = Get-AppxPackage -Name "MyWhooshTechnologyService.MyWhoosh"
# Locates: MyWhooshTechnologyService.MyWhoosh_eps1123pz0kt0!MYWHOOSH
```

### Sandbox Navigation

FIT files in the UWP version are stored deep within the `LocalState` sandbox. The Sync Monitor navigates these folders automatically when a UWP installation is detected.

## 2. Automation: Taskbar & Shortcuts

Since Windows doesn't allow pinning scripts (.ps1) directly to the taskbar, we use a helper to create an executable shortcut.

1. **Create Shortcut**: Run `.\CreateShortcut.ps1` in PowerShell.
2. **Desktop Launch**: A **myWhoosh2Garmin** icon will appear on your desktop.
3. **Pin to Taskbar**: Right-click the desktop icon and select **"Pin to taskbar"**.
4. **Usage**: Clicking the taskbar icon will:
   - Launch MyWhoosh immediately.
   - Start the Sync Monitor in the background.
   - Automatically handle **Poetry** and **Virtual Environment** setup on the first run.
   - Automatically upload every workout you complete during the session.

## 3. Technical Implementation

For details on how the sync engine handles duplicates, multi-activity sessions, and monitoring loops, please refer to the **[Technical Details](TECHNICAL_DETAILS.md)** guide.
