#!/bin/bash

set -e

echo "Setting up dark mode for GNOME and applications..."

echo "Configuring GNOME desktop settings for dark mode"
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'

echo "Creating GTK 3.0 configuration"
mkdir -p ${HOME}/.config/gtk-3.0
cat > ${HOME}/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
EOF

echo "Creating GTK 4.0 configuration"
mkdir -p ${HOME}/.config/gtk-4.0
cat > ${HOME}/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-recent-files-enabled=0
gtk-application-prefer-dark-theme=1
EOF

echo "Setting GTK_THEME environment variable"
mkdir -p ${HOME}/.config/environment.d
echo "GTK_THEME=Adwaita-dark" > ${HOME}/.config/environment.d/gtk-dark.conf

echo "Installing Flatpak dark theme support"
if command -v flatpak &> /dev/null; then
    flatpak install -y org.gtk.Gtk3theme.Adwaita-dark || echo "Adwaita-dark theme for Flatpak already installed"
    
    echo "Configuring Chrome Flatpak for dark mode"
    if flatpak list | grep -q com.google.Chrome; then
        flatpak override --user --env=GTK_THEME=Adwaita-dark com.google.Chrome
        flatpak override --user --filesystem=xdg-config/gtk-3.0:ro --filesystem=xdg-config/gtk-4.0:ro com.google.Chrome
        echo "Chrome Flatpak configured for dark mode"
    else
        echo "Chrome Flatpak not found, skipping Chrome-specific configuration"
    fi
else
    echo "Flatpak not installed, skipping Flatpak theme installation"
fi

echo "Dark mode setup complete!"
echo "Note: You may need to log out and back in for all changes to take effect"