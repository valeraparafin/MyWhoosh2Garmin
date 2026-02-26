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

The easiest way to use the monitor is through the automated scripts that stay active while you ride. They will automatically handle **Poetry** installation and virtual environment setup.

### Windows

1. Run `.\CreateShortcut.ps1` in PowerShell.
2. A **myWhoosh2Garmin** shortcut will appear on your desktop.
3. Pin it to your Taskbar for easy one-click access.
4. The first run will automatically install Poetry and dependencies.
5. See **[Windows Support](WINDOWS_SUPPORT.md)** for more details.
   <img width="957" height="514" alt="MyWhoosh monitoring Win11 success" src="https://github.com/user-attachments/assets/77539a43-dc63-4c5e-bc02-8b03e469afb6" />


### macOS (Experimental)
1. Ensure you have AppleScript support and the MyWhoosh app installed.
2. Follow the simplified [QUICK_START_MAC.md](QUICK_START_MAC.md) guide.

<h2>🛠️ Manual Usage</h2>

If you prefer to run the sync engine manually via Poetry:

1. Install Poetry: `pip install poetry`.
2. Initialize environment: `poetry install`.
3. Run the monitor:
   ```bash
   poetry run python myWhoosh2Garmin.py --monitor
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
