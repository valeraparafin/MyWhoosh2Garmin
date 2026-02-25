<h1 align="center" id="title">myWhoosh2Garmin</h1>

<p align="center">
  <strong>Automated activity uploader for MyWhoosh Indoor Cycling</strong>
</p>

<h2>🧐 Features</h2>

- **Seamless Sync**: Automatically detects and uploads your rides to Garmin Connect.
- **Continuous Monitoring**: Stays active while you ride; syncs multiple workouts in a single session without restarts.
- **Smart Duplicate Detection**: Uses MD5 fingerprinting to ensure no training is ever uploaded twice.
- **Quality Fixes**: Automatically fixes missing Power and Heart Rate averages for better analytics.
- **Store Version Support**: Fully compatible with both regular and Microsoft Store (UWP) versions.

<h2>🚀 Quick Start (Recommended)</h2>

The easiest way to use the monitor is through the automated scripts that stay active while you ride.

### Windows

1. Run `.\CreateShortcut.ps1` in PowerShell.
2. A **myWhoosh2Garmin** shortcut will appear on your desktop.
3. Pin it to your Taskbar for easy one-click access.
4. See **[Windows Support](WINDOWS_SUPPORT.md)** for more details.
<img width="957" height="1015" alt="How monitoring process looks on win11" src="https://github.com/user-attachments/assets/86c42444-b854-4d2d-9773-f3175f9f5dd6" />

### macOS

1. Use the provided AppleScript monitor in the `apple-script` folder.
2. See **[macOS Support](apple-script/README.md)** for setup instructions.

<h2>🛠️ Manual Usage</h2>

If you prefer to run the sync engine manually:

1. Install dependencies: `pip install garth fit_tool psutil`.
2. Run the monitor directly:
   ```bash
   python myWhoosh2Garmin.py --monitor
   ```

<h2>ℹ️ Further Information</h2>

- **[Technical Details](TECHNICAL_DETAILS.md)**: Learn about the sync engine, duplicate detection, and monitoring logic.
- **[Windows Support](WINDOWS_SUPPORT.md)**: Specifics for UWP support and taskbar automation.
- **[macOS Support](apple-script/README.md)**: Instructions for AppleScript integration.

<h2>💻 Technical Stack</h2>

- <a href="https://github.com/matin/garth">Garth</a> (Garmin Connect API)
- <a href="https://bitbucket.org/stagescycling/fit_tool/src/main/">Fit_tool</a> (FIT parsing)
- **psutil** (Process monitoring)
- **MD5** (Deduplication)

