#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root (using sudo)."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME=$(eval echo ~$SUDO_USER)

# Update system
echo "Updating system..."
apt update && apt upgrade -y

# Ask user if they are installing on an NVIDIA system
read -p "Are you installing on a system with an NVIDIA GPU? (yes/no): " nvidia_choice

# Install required packages
echo "Installing DWM package dependencies..."
apt install -y \
    thunar xorg xserver-xorg curl firefox-esr xinit x11-xserver-utils feh picom gdm3 \
    pavucontrol fonts-hack-ttf dwm libimlib2-dev fonts-font-awesome adwaita-qt pamixer gamemode rofi flameshot wget \
    zsh timeshift pipewire pipewire-audio pipewire-alsa \
    kitty lxappearance network-manager-gnome dunst build-essential libx11-dev libxft-dev libxinerama-dev \
    curl unzip qt5ct qt6ct xfce4-settings gnome-themes-extra

# Install Starship (since it's not in apt)
echo "Installing Starship prompt..."
sudo -u "$SUDO_USER" sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y'

# Install NVIDIA drivers if selected
if [[ "$nvidia_choice" == "yes" ]]; then
    echo "Installing NVIDIA drivers..."
    apt install -y nvidia-driver nvidia-settings
    echo "Enabling NVIDIA DRM Modeset..."
    echo 'options nvidia_drm modeset=1' > /etc/modprobe.d/nvidia-drm.conf
    update-initramfs -u
fi

# Always install dwm from source
echo "Compiling and installing dwm from source..."
DWM_DIR="$SCRIPT_DIR/dwm"

if [[ ! -d "$DWM_DIR" ]]; then
    echo "Error: dwm directory not found inside dwm-debian. Exiting."
    exit 1
fi

cd "$DWM_DIR"
make clean install
cd "$SCRIPT_DIR"

# Enable and start GDM
echo "Enabling GDM..."
systemctl enable gdm3

# Prompt for Dotfile Installation
read -p "Do you want to install custom DWM dotfiles? (yes/no): " dotfiles_choice

if [[ "$dotfiles_choice" == "yes" ]]; then
    echo "Installing Stocky's DWM dotfiles..."
    
    # Ensure .config exists and copy configuration files
    mkdir -p "$USER_HOME/.config"
    cp -r "$SCRIPT_DIR/.config" "$USER_HOME/"
    
    # Copy .xprofile
    cp "$SCRIPT_DIR/.xprofile" "$USER_HOME/.xprofile"
    
    # Ensure Pictures folder exists and copy wallpapers
    echo "Creating Pictures directory and copying wallpapers..."
    mkdir -p "$USER_HOME/Pictures/wallpapers"
    cp -r "$SCRIPT_DIR/wallpapers"/* "$USER_HOME/Pictures/wallpapers/"
    
    # Set correct permissions
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.config" "$USER_HOME/.xprofile" "$USER_HOME/Pictures"

    echo "Dotfiles and wallpapers installed successfully."

    # Install Hack Nerd Font
    echo "Installing Hack Nerd Font..."
    sudo -u "$SUDO_USER" bash -c '
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts
        wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
        unzip Hack.zip
        fc-cache -fv
    '
    echo "Hack Nerd Font installed successfully."

    # Configure Dark Mode for GTK
    echo "Enabling GTK Dark Mode..."
    sudo -u "$SUDO_USER" bash -c '
        mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
        echo -e "[Settings]\ngtk-theme-name=Adwaita-dark\ngtk-application-prefer-dark-theme=1" > ~/.config/gtk-3.0/settings.ini
        echo -e "[Settings]\ngtk-theme-name=Adwaita-dark\ngtk-application-prefer-dark-theme=1" > ~/.config/gtk-4.0/settings.ini
        echo 'gtk-theme-name="Adwaita-dark"' > ~/.gtkrc-2.0
    '
    echo "GTK Dark Mode enabled."

    # Configure Dark Mode for Qt
    echo "Enabling Qt Dark Mode..."
    echo 'export QT_QPA_PLATFORMTHEME=qt5ct' >> "$USER_HOME/.xprofile"
    echo 'export QT_QPA_PLATFORMTHEME=qt6ct' >> "$USER_HOME/.xprofile"
    echo "Qt Dark Mode enabled."

    # Configure Thunar Dark Mode
    echo "Enabling Thunar Dark Mode..."
    sudo -u "$SUDO_USER" bash -c '
        mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml

        tee ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml > /dev/null << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net">
    <property name="ThemeName" type="string" value="Adwaita-dark"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
  </property>
</channel>
EOF

        # Apply settings
        xfconf-query -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
        xfconf-query -c xsettings -p /Net/IconThemeName -s "Adwaita"

        # Restart xfsettingsd to apply the theme immediately
        pkill xfsettingsd || true
        nohup xfsettingsd --no-daemon > /dev/null 2>&1 &
    '
    echo "Thunar Dark Mode enabled."

else
    echo "Skipping dotfile installation."
fi

# Ensure dwmblocks directory exists
DWM_BLOCKS_DIR="$SCRIPT_DIR/dwmblocks"

if [[ -d "$DWM_BLOCKS_DIR" ]]; then
    cd "$DWM_BLOCKS_DIR"
    
    # Apply custom config.h if exists
    if [[ -f "$DWM_BLOCKS_DIR/config.h" ]]; then
        echo "Applying custom config.h for dwmblocks..."
        cp "$DWM_BLOCKS_DIR/config.h" "$DWM_BLOCKS_DIR/config.h.bak" # Backup
    fi
    
    make clean install
    cd "$SCRIPT_DIR"

    # Ensure dwmblocks starts on login
    if ! grep -q "dwmblocks &" "$USER_HOME/.xprofile"; then
        echo "Adding dwmblocks to startup..."
        echo "dwmblocks &" >> "$USER_HOME/.xprofile"
    fi
else
    echo "Warning: dwmblocks directory not found. Skipping installation."
fi

# Ask if user wants to copy the xrandr config
read -p "Do you want to keep the xrandr display setup? (yes/no): " xrandr_choice

if [[ "$xrandr_choice" == "no" ]]; then
    echo "Commenting out xrandr setup in .xprofile..."
    sed -i '/^xrandr --output/s/^/# /' "$USER_HOME/.xprofile"
fi

# Ask user if they want to set up OpenSSH
read -p "Do you want to set up OpenSSH for remote access? (yes/no): " ssh_choice

if [[ "$ssh_choice" == "yes" ]]; then
    echo "Installing and configuring OpenSSH..."
    apt install -y openssh-server

    # Enable password authentication and allow root login
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # Restart and enable SSH service
    systemctl enable ssh
    systemctl restart ssh
    echo "OpenSSH has been set up and enabled."
else
    echo "Skipping OpenSSH setup."
fi

echo "Installation complete."
