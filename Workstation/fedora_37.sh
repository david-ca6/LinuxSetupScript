#!/bin/bash

# update package
sudo dnf upgrade --refresh -y
sudo dnf check-update
sudo dnf update

# microsoft vscode repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# rpm fusion repo
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# update package
sudo dnf upgrade --refresh -y
sudo dnf check-update
sudo dnf update

# remove default software
sudo dnf remove -y evolution                                                # email client, use use thunderbird flatpak
sudo dnf remove -y firefox                                                  # web browser, we use librewolf and chrome flatpak
sudo dnf remove -y totem                                                    # video player, we use vlc flatpak
sudo dnf remove -y libswscale-free-5.1.2-1.fc37                             # we need to use ffmepg from rpmfusion for better compatibility

# install software
sudo dnf install -y ffmpeg                                                  # video encoder/decoder
sudo dnf install -y htop                                                    # htop
sudo dnf install -y nvtop                                                   # nvidia top
sudo dnf install -y ntfs-3g                                                 # ntfs 
sudo dnf install -y toolbox distrobox                                       # container tool
sudo dnf install -y svn git                                                 # code versioning
sudo dnf install -y python3 python3-pip                                     # python
sudo dnf install -y autoconf automake cmake make clang gcc                  # build tool
sudo dnf install -y kernel-devel kernel-headers                             # kernel header
sudo dnf install -y gnome-tweaks                                            # gnome customization app
sudo dnf install -y gnome-extensions-app                                    # extension for gnome
sudo dnf install -y docker                                                  # docker container
sudo dnf install -y lm_sensors                                              # temp sensors
sudo dnf install -y stress                                                  # stress tool test
sudo dnf install -y VirtualBox kmod-VirtualBox                              # virtualbox
sudo dnf install -y xrdp                                                    # remote desktop
sudo dnf install -y wine wine-core                                          # windows compatibility
sudo dnf install -y cockpit                                                 # cockpit remote management

# install library
sudo dnf install -y SDL2 SDL2-devel
sudo dnf install -y SDL2_image SDL2_image-devel
sudo dnf install -y SDL2_mixer SDL2_mixer-devel
sudo dnf install -y SDL2_ttf SDL2_ttf-devel
sudo dnf install -y SDL2_net SDL2_net-devel
sudo dnf install -y libcurl libcurl-devel
sudo dnf install -y libnotify libnotify-devel

if lscpu | grep -q 'Intel'; then
    echo Intel
  sudo dnf install -y intel-undervolt                                       # undervolt intel cpu / cpu monitoring
fi
if lscpu | grep -q 'AMD'; then
    echo AMD
fi

sudo dnf install -y code        

echo ""
echo "Manual Step:"
echo "Run flatpak.sh"
echo "Run vscode.sh"
echo "Open ExtensionManager"
echo "Go to Browse and install the folowing extension:"
echo "- AppIndicator and KStatusNotifierItem Support"
echo "- Desktop Icons NG (DING)"
echo "- Removable Drive Menu"
echo "- Dash to Panel"
echo "- ArcMenu"
echo "- ddterm"
echo ""
echo "Press a key to continue"
read -n 1 -s

# enable/disable gnome extensions
gnome-extensions disable launch-new-instance@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable places-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable window-list@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable apps-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions disable background-logo@fedorahosted.org

gnome-extensions enable drive-menu@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable ddterm@amezin.github.com
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable ding@rastersoft.com

# set gnome settings
gsettings set org.gnome.desktop.wm.preferences button-layout appmenu:minimize,maximize,close
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true

# start service
sudo systemctl enable cockpit.socket
sudo systemctl start cockpit

sudo systemctl enable xrdp
sudo systemctl start xrdp 

sudo firewall-cmd --permanent --add-port=3389/tcp
sudo firewall-cmd --permanent --add-port=9090/tcp

sudo firewall-cmd --reload 

sudo chcon --type=bin_t /usr/sbin/xrdp 
sudo chcon --type=bin_t /usr/sbin/xrdp-sesman 

# add user to vboxusers
sudo usermod -a -G vboxusers $USER

# making directory
mkdir ~/VMs
mkdir ~/Datas
mkdir ~/Scripts
mkdir ~/Workspaces

if lspci | grep -q 'Intel'; then
    echo Intel
fi
if lspci | grep -q 'AMD'; then
    echo AMD
fi
if lspci | grep -q 'NVIDIA'; then
    #echo "=====> For Nvidia GPU install nvidia driver from nvidia website (install after reboot) <====="
    sudo dnf install -y xorg-x11-drv-nvidia
    sudo dnf install -y xorg-x11-drv-nvidia-cuda
fi

# install rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

# install go toolchain
wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz
rm go1.20.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

echo ""
echo "" 
echo "Install & Configuration DONE"
echo "Welcome to Fedora Workstation 37 for CA6 Developper"
echo "Please reboot your computer"
echo ""
echo ""
echo "READ ME:"
echo ""
echo "- import ArcMenu.conf in ArcMenu"
echo "- import DashToPanel.conf in Dash To Panel"
echo ""
echo "- MS teams and office 365 to be installed in edge or chrome as webaps"
echo ""
echo "- ~/VMs, ~/Datas, ~/Workspaces, can also be used as mount point for drive"
echo ""
echo "- Recomanded Shortcut:"
echo "    Super     => Raven Menu    (arcmenu)"
echo "    Super + R => Launcher/Run  (arcmenu)"
echo "    Super + Q => Kill/Quit     (gnome)"
echo "    Super + T => Terminal      (ddterm)"
echo ""
echo ""
