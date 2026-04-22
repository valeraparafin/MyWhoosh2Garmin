# Define the JSON config file path
$configFile = "$PSScriptRoot\mywhoosh_config.json"
$myWhooshApp = "MyWhoosh"

# Check if the JSON file exists and read the stored path
if (Test-Path $configFile) {
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    $mywhooshPath = $config.path
    $isUWP = $config.isUWP
}
else {
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
    }
    else {



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
}
else {


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
}

# --- Poetry & Environment Auto-Manager ---
$pythonCmd = "python"
if (-not (Get-Command $pythonCmd -ErrorAction SilentlyContinue)) { $pythonCmd = "python3" }

# 1. Check if Poetry is installed
if (-not (Get-Command "poetry" -ErrorAction SilentlyContinue) -and -not ($pythonCmd -and (&$pythonCmd -m poetry --version 2>$null))) {
    Write-Host "Poetry not found. Attempting to install..." -ForegroundColor Cyan
    &$pythonCmd -m pip install poetry
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install Poetry via pip. Please install it manually: https://python-poetry.org/docs/#installation" -ForegroundColor Red
        exit 1
    }
}

# 2. Ensure dependencies are installed (virtual environment)
if (-not (Test-Path "$PSScriptRoot\.venv")) {
    Write-Host "Setting up virtual environment and installing dependencies..." -ForegroundColor Cyan
    &$pythonCmd -m poetry install
}

# 3. Finally, run the sync engine
Write-Host "Launching myWhoosh2Garmin Monitor..." -ForegroundColor Green
&$pythonCmd -m poetry run python myWhoosh2Garmin.py --monitor

Write-Host "`nDone! Press any key to close this window..." -ForegroundColor Gray

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

