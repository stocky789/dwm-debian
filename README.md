# DWM-Debian Installation Script

![DWM Logo](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Dwm-logo.svg/1920px-Dwm-logo.svg.png)

## Overview
This script automates the installation and configuration of **dwm** (Dynamic Window Manager) on **Debian 12**. It installs essential dependencies, sets up a display manager, and applies a customized configuration.

## Features
- 🚀 Installs required system packages, fonts, and utilities.
- 🎮 Detects and installs NVIDIA drivers if applicable.
- 🔧 Builds and installs `dwm` from source.
- 🎨 Copies dotfiles for custom `dwm` configuration.
- 📡 Configures OpenSSH for remote access (optional).
- 🖥️ Enables `GDM3` as the default display manager.

## Installation
### 1. Download and Run the Script
```bash
wget https://your-repo-url/dwm-debian-install.sh -O dwm-install.sh
chmod +x dwm-install.sh
sudo ./dwm-install.sh
```

### 2. Follow the Prompts
- Choose whether to install **NVIDIA drivers**.
- Decide if you want to **install custom dotfiles**.
- Opt to **enable OpenSSH** for remote access.

## Customization
- Modify `dwm` patches and settings in **`config.h`** then recompile in dwm directory (sudo make install)
- Quickly toggle on or off patches in **`patches.h`**
- Place your autostart scripts in **`~/.xprofile`**.
- Use `picom` for transparency and compositing.

## Uninstallation
```bash
sudo apt remove --purge dwm
rm -rf ~/.config/dwm ~/.xprofile
```

## Troubleshooting
- If `dwm` doesn't start, ensure `~/.xprofile` contains:
  ```bash
  exec dwm
  ```
- Check logs: `journalctl -xe` or `startx 2>&1 | tee dwm.log`
- If you get a gdm3.service failure during the initial ./install.sh - rerun it.

## Credits
This script is inspired by **bakkeby dwm-flexipatch** and **suckless at [suckless.org](https://suckless.org/)** modified for Debian 12.

---
Made for Debian users!

