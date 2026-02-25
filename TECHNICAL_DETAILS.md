# myWhoosh2Garmin: Technical Details

This document explains the core logic and technical implementation of the sync engine.

## 1. Automated Monitoring Loop

The core feature of the monitor is its ability to stay active and wait for new activities without manual intervention.

- **Process Detection**: Uses the `psutil` library to scan for running processes named `MyWhoosh`.
- **Interval**: Checks the FIT file directory every 60 seconds.
- **Single Authentication**: The `garth` session is initialized once at startup. Subsequent syncs reuse the same session, avoiding redundant login requests and potential rate-limiting.
- **Graceful Termination**: When the MyWhoosh process is no longer detected, the engine performs one final scan for any last-minute activities and then exits.

## 2. Multi-Activity Support

The engine is designed to handle multiple workouts completed within a single game session.

- **File Scanning**: Instead of only looking for the "latest" file, it scans the entire data directory for all files matching the pattern `MyNewActivity-*.fit`.
- **Atomic Processing**: Each activity is cleaned (averages fixed, temperature removed) and uploaded individually.

## 3. Smart Duplicate Detection

To prevent duplicate uploads (especially since MyWhoosh sometimes reuses filenames or leaves old files), the monitor uses MD5 fingerprinting.

- **Hash Calculation**: For every discovered FIT file, an MD5 hash is calculated based on the file content.
- **Database**: Hashes of successfully uploaded activities are stored in `processed_activities.json`.
- **Verification**: Before processing any file, its hash is checked against the database. If a match is found, the file is skipped automatically.

## 4. FIT File Optimization

The monitor performs several cleanup tasks to improve the quality of the data in Garmin Connect:

- **Missing Averages**: Forces recalculation of average Power and Heart Rate values if the game didn't populate them correctly.
- **Data Stripping**: Removes internal or invalid data fields (like temperature) that can sometimes cause display issues in third-party platforms.
- **Timestamping**: Reprocessed files are saved with a timestamped suffix to preserve the original data while ensuring each sync has a unique filename in the backup folder.

## 5. Dependency Management

The project uses **Poetry** for robust dependency resolution and environment isolation.

- **Virtual Environment**: All runs are performed inside a dedicated virtual environment, preventing conflicts with global Python packages.
- **Automated Setup**: The launch scripts (`MyWhooshMonitor.ps1` and macOS AppleScript) automatically detect missing dependencies or Poetry itself and handle the initialization.
- **Reproducibility**: `pyproject.toml` and `poetry.lock` ensure that every installation uses the exact same versions of `garth`, `fit-tool`, and `psutil`.
