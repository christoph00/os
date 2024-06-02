#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

cd /tmp
git clone https://github.com/catppuccin/kde.git catppuccinkde
cd catppuccinkde
rm -f install.sh
curl -sL -o /tmp/catppuccinkde/install.sh https://raw.githubusercontent.com/sernik-tech/member-images/main/config/scripts/catppuccin-plasma.sh
chmod +x install.sh
# Latte
cd /tmp/catppuccinkde && /tmp/catppuccinkde/install.sh 1 9 1
# Mocha
cd /tmp/catppuccinkde && /tmp/catppuccinkde/install.sh 4 9 1

#
# Papirus icon pack (From source)
#
cd /tmp
wget -qO- https://git.io/papirus-icon-theme-install | sh

#
# Tela icon pack
#
cd /tmp
git clone https://github.com/vinceliuice/Tela-icon-theme.git
cd Tela-icon-theme
chmod +x install.sh
./install.sh -c -d /usr/share/icons

#
# Papirus-folders
#
cd /tmp
git clone https://github.com/catppuccin/papirus-folders.git
cd papirus-folders
cp -r /tmp/papirus-folders/src/* /usr/share/icons/Papirus
chmod +x papirus-folders
./papirus-folders -t Papirus-Light -C cat-latte-green
./papirus-folders -t Papirus-Dark -C cat-mocha-green


#
# posy cursors
#
cd /tmp
git clone "https://github.com/AuraHerreroRuiz/Posys-improved-cursors-linux.git"
cd Posys-improved-cursors-linux
git checkout "$(git tag --sort=tag --list 'v[0-9]*' | tail -n 1)"
cp -r Themes/* /usr/share/icons/