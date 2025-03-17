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

## Manual Installation
If you prefer a manual setup, install dependencies:
```bash
sudo apt update && sudo apt install -y \
    thunar xorg xserver-xorg xinit x11-xserver-utils feh picom gdm3 \
    pavucontrol fonts-hack fonts-font-awesome pamixer gamemode rofi flameshot wget \
    zsh timeshift pipewire pipewire-pulse pipewire-alsa \
    kitty lxappearance network-manager-gnome dunst build-essential \
    libx11-dev libxft-dev libxinerama-dev
```

Then clone and compile `dwm`:
```bash
git clone https://github.com/your-repo/dwm.git
cd dwm
make clean install
```

## Customization
- Modify `dwm` patches and settings in **`config.h`** before compiling.
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

## Credits
This script is inspired by **Stocky's Arch DWM setup**, modified for Debian 12.

---
Made with ❤️ for Debian users!

