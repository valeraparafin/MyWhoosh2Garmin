# 🏁 Quick Start: MyWhoosh to Garmin (macOS)

Follow these 3 simple steps to start syncing your rides automatically.

## 1. Login to Garmin (One-time)
Double-click the **`Login.command`** file in this folder.
- A terminal window will open.
- Enter your Garmin **Email** and **Password** when prompted.
- Once it says "Successfully authenticated!", you can close the window.

## 2. Install the App
1. Drag **`myWhooshSync.app`** to your **Applications** folder.
2. Open **System Settings** -> **Privacy & Security** -> **Full Disk Access**.
3. Click the `+` button and add **`myWhooshSync.app`**. This allows it to "see" when you finish a ride.

## 3. Just Ride!
- Open **`myWhooshSync.app`** once to start it in the background. (It won't show an icon in the Dock, this is normal!)
- **Silent Watcher**: Once opened, the app stays running and checks for MyWhoosh every 30 seconds. You can ride today, tomorrow, or next week—it will catch every ride automatically.
- **Tip (Optional)**: To make it truly "set and forget", add it to your Mac's **Login Items** (System Settings -> General -> Login Items). That way it starts automatically whenever you turn on your computer.

---
### 💡 Troubleshooting
- **No sync?** Make sure you gave the app "Full Disk Access" (Step 2).
- **Check logs:** You can see what's happening by running: `cat /tmp/myWhooshSync.log` in Terminal.
