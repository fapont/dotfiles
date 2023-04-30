#!/usr/bin/env bash

####################
## Util functions ##
####################

is_installed() {
  pacman -Qi $1 &> /dev/null
  return $?
}

install_package_list() {
    for paquet in "${$1[@]}"
    do
        if ! is_installed $paquet; then
            sudo yay -S $paquet --noconfirm --removemake --cleanafter
            printf "\n"
        else
            printf '%s is already installed on your system!\n' "$paquet"
            sleep 1
        fi
    done
}

##################
## Installation ##
##################

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

# Install prerequisities packages required to use AUR (base-devel, git, yay)
printf "Install prerequisities packages required to use AUR"
pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd $HOME &&rm -rf yay

# Install packages
printf "Installing desktop environment packages...\n"
desktop=(bspwm polybar sxhkd dunst rofi picom feh alacritty ranger)
install_package_list desktop

printf "Installing utils packages...\n"
utils=(zsh lsd jq yq polkit-gnome xorg-xprop xorg-xkill) # TODO: voir à quoi sert les trucs xorg
install_package_list utils

printf "Installing music packages...\n"
musics=(playerctl mpd ncmpcpp pamixer mpc) #TODO: clean
install_package_list musics


printf "Installing fonts packages...\n"
fonts=(ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-terminus-nerd ttf-inconsolata ttf-joypixels papirus-icon-theme)
install_package_list fonts

printf "Installing development packages...\n"
dev=()
#TODO: installer terraform, helm, helmfile, awsclid, gcloud, vscode, ...
install_package_list dev


#wallpaper=(libwebp webp-pixbuf-loader) #used to load webp images and to not have heavy repo (TODO: replace by image download)

printf "DONE !"
sleep 2
clear



####### TODO la suite ######""


logo "Cloning Rice!"
[ -d ~/dotfiles ] && rm -rf ~/dotfiles
printf "Cloning rice from https://github.com/gh0stzk/dotfiles\n\n"
cd $HOME
git clone --depth=1 https://github.com/gh0stzk/dotfiles.git
sleep 2
clear

logo "Backup your files"
printf "Backup files will be stored in %s%s%s/.RiceBackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 5

if [ ! -d "$HOME/.RiceBackup" ]; then 
	mkdir -p "${HOME}"/.RiceBackup
fi

[ -d ~/.config/bspwm ] && mv ~/.config/bspwm ~/.RiceBackup/bspwm-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/termite ] && mv ~/.config/termite ~/.RiceBackup/termite-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/alacritty ] && mv ~/.config/alacritty ~/.RiceBackup/alacritty-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/picom ] && mv ~/.config/picom ~/.RiceBackup/picom-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/rofi ] && mv ~/.config/rofi ~/.RiceBackup/rofi-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/eww ] && mv ~/.config/eww ~/.RiceBackup/eww-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/sxhkd ] && mv ~/.config/sxhkd ~/.RiceBackup/sxhkd-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/dunst ] && mv ~/.config/dunst ~/.RiceBackup/dunst-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/gtk-3.0 ] && mv ~/.config/gtk-3.0 ~/.RiceBackup/gtk-3.0-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/polybar ] && mv ~/.config/polybar ~/.RiceBackup/polybar-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/mpd ] && mv ~/.config/mpd ~/.RiceBackup/mpd-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/ncmpcpp ] && mv ~/.config/ncmpcpp ~/.RiceBackup/ncmpcpp-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.RiceBackup/nvim-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/ranger ] && mv ~/.config/ranger ~/.RiceBackup/ranger-backup-"$(date +%Y.%m.%d-%H.%M.%S)"
[ -d ~/.config/zsh ] && mv ~/.config/zsh ~/.RiceBackup/zsh-backup-"$(date +%Y.%m.%d-%H.%M.%S)"

[ -f ~/.zshrc ] && mv ~/.zshrc ~/.RiceBackup/.zshrc-backup-"$(date +%Y.%m.%d-%H.%M.%S)"

printf "%s%sDone!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2
clear

logo "Copying Rice.."
printf "Copying files to respective directories..\n"

if [ ! -d $HOME/.config ]; then
	mkdir -p $HOME/.config
	cp -Rf $HOME/dotfiles/config/* $HOME/.config/
else
	cp -Rf $HOME/dotfiles/config/* $HOME/.config/
fi

if [ ! -d $HOME/.local/bin ]; then
	mkdir -p $HOME/.local/bin
	cp -Rf $HOME/dotfiles/misc/bin/* $HOME/.local/bin/
else
	cp -Rf $HOME/dotfiles/misc/bin/* $HOME/.local/bin/
fi

if [ ! -d $HOME/.local/share/applications ]; then
	mkdir -p $HOME/.local/share/applications
	cp -Rf $HOME/dotfiles/misc/applications/* $HOME/.local/share/applications/
else
	cp -Rf $HOME/dotfiles/misc/applications/* $HOME/.local/share/applications/
fi

if [ ! -d $HOME/.local/share/asciiart ]; then
	mkdir -p $HOME/.local/share/asciiart
	cp -Rf $HOME/dotfiles/misc/asciiart/* $HOME/.local/share/asciiart/
else
	cp -Rf $HOME/dotfiles/misc/asciiart/* $HOME/.local/share/asciiart/
fi

if [ ! -d $HOME/.local/share/fonts ]; then
	mkdir -p $HOME/.local/share/fonts
	cp -Rf $HOME/dotfiles/misc/fonts/* $HOME/.local/share/fonts/
else
	cp -Rf $HOME/dotfiles/misc/fonts/* $HOME/.local/share/fonts/
fi

cp -f $HOME/dotfiles/home/.zshrc $HOME

cp -r $HOME/dotfiles/misc/firefox/chrome $HOME/.mozilla/firefox/*.default-release/
cp -r $HOME/dotfiles/misc/firefox/user.js $HOME/.mozilla/firefox/*.default-release/

printf "%s%sFiles copied succesfully!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2
clear

logo "Installing needed packages from AUR"				 
yay -S eww nerd-fonts-cozette-ttf scientifica-font --removemake --cleanafter
sleep 2	  
clear

logo "Reloading fonts.."
fc-cache -rv >/dev/null 2>&1
printf "%s%sFonts reloaded succesfully!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2
clear

logo "Enabling MPD service"
systemctl --user enable mpd.service
systemctl --user start mpd.service
printf "%s%sDone!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2
clear

logo "Installation finished"
printf "%s%sPlease reboot, then select bspwm in your login manager and log in.%s\n\n" "${BLD}" "${CRE}" "${CNC}"
# Change default shell
chsh -s /usr/bin/zsh
zsh
