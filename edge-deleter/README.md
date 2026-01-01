# 🗑️ Edge Vanisher (Permanent Remover)

This tool is designed to completely uninstall Microsoft Edge and prevent it from re-installing during Windows Updates.

## 📦 Files in this folder:
* **`EdgeVanisher.ps1`**: The main PowerShell engine that deletes Edge files, registry keys, and services.
* **`RunVanisher.bat`**: The easy launcher. Use this to run the script without dealing with PowerShell settings.

## 🚀 How to Use:
1. Download both files in this folder.
2. Right-click **`RunVanisher.bat`** and select **Run as Administrator**.
3. A blue window will appear. Wait for it to say "DONE!" and then **Restart your PC**.

## 🛡️ What makes this different?
Instead of just deleting files, this script creates "Vaccine" folders with restricted permissions. Windows Update will see these folders and think Edge is already there, preventing it from force-installing the browser again.

---
**Note:** Removing Edge may disable the Windows Widgets panel.