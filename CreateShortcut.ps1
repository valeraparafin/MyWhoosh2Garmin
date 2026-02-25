# CreateShortcut.ps1
# This script creates a shortcut to run MyWhooshMonitor on the desktop.

$scriptPath = Join-Path $PSScriptRoot "MyWhooshMonitor.ps1"
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "MyWhoosh Monitor.lnk"

# PowerShell parameters setup
$powershellPath = (Get-Command powershell.exe).Source
$arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`""

# Attempt to find the MyWhoosh icon
$iconPath = $powershellPath # PowerShell icon by default
$uwpPackage = Get-AppxPackage -Name "MyWhooshTechnologyService.MyWhoosh" -ErrorAction SilentlyContinue
if ($uwpPackage) {
    # Attempt to find the executable path via the manifest
    $manifest = Get-AppxPackageManifest $uwpPackage
    $relPath = $manifest.Package.Applications.Application | Where-Object { $_.Id -eq "MYWHOOSH" } | Select-Object -ExpandProperty Executable
    if ($relPath) {
        $fullExecPath = Join-Path $uwpPackage.InstallLocation $relPath
        if (Test-Path $fullExecPath) {
            $iconPath = $fullExecPath
        }
    }
}

# Creating the shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $powershellPath
$Shortcut.Arguments = $arguments
$Shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.IconLocation = "$iconPath, 0"
$Shortcut.Description = "Start MyWhoosh Monitoring"
$Shortcut.Save()

Write-Host "---"
Write-Host "The 'MyWhoosh Monitor' shortcut has been successfully created on your desktop!" -ForegroundColor Green
Write-Host "Now you can:"
Write-Host "1. Drag this shortcut to the Taskbar to pin it."
Write-Host "2. Start monitoring with a single click."
Write-Host "---"
