#!/usr/bin/bash

if [ $EUID = "0" ]; then
	echo "Do not run this as root/sudo!! The script does it for you as certain parts of it must be run as a regular user"
	exit
fi

if [ -e /usr/bin/doas ]; then
	DOAS=/usr/bin/doas
elif [ -e /usr/bin/sudo ]; then
	DOAS=/usr/bin/sudo
else 
	DOAS="su -c"
	read -rp 'sudo and doas were not found, using su -c. Make sure your user is in the wheel group before continuing.
	Press enter to continue. '
fi

read -rp 'This script is largely untested so run with caution. Press ctrl+c at any time to exit. Press enter to continue anyway.'

echo -e \\n"Updating system"\\n

sleep 1
$DOAS pacman -Syu --noconfirm

clear

echo -e \\n"Installing reflector, and rsync, if not already installed"\\n

sleep 1
$DOAS pacman -S --noconfirm reflector rsync

sleep 2
clear

echo -e \\n"Updating mirrorlist"\\n
$DOAS reflector --latest 15 --sort rate --save /etc/pacman.d/mirrorlist

clear

while true; do
	read -rp "Do you have an intel or amd cpu?
Type your answer in all lowercase: " cpu
	case $cpu in
		"intel")
			$DOAS pacman -S --noconfirm intel-ucode
			break;;
		"amd")
			$DOAS pacman -S --noconfirm amd-ucode
			break;;
	esac
done

if [ -e /usr/bin/grub-mkconfig ]; then
	$DOAS grub-mkconfig -o /boot/grub/grub.cfg
fi

clear

echo -e \\n "Which text editor do you want?

Nano, best for beginners.
Vim, more advanced (and easier to get stuck in)
ee, traditional on bsd systems, incredibly simple and best for beginners next to nano.
Emacs. (don't)"

while true; do
	read -rp "Type the full name in all lowercase to select: " editor
	case $editor in
		"nano")
			echo
			$DOAS pacman -S --confirm nano
			break;;
		"vim")
			echo
			$DOAS pacman -S --noconfirm vim
			break;;
		"ee")
			echo
			$DOAS pacman -S --noconfirm ee-editor
			break;;
		"emacs")
			echo
			echo please stop
			echo
			$DOAS pacman -S --noconfirm emacs
			break;;
		*)
			echo Invalid option
	esac
done

clear

echo
sleep 1
echo Installing yay, an AUR helper
sleep 1

$DOAS pacman -S --noconfirm base-devel

function installyay {
git clone https://aur.archlinux.org/yay.git
cd yay || exit
$DOAS pacman -S --noconfirm go
makepkg -si
cd ..
rm -rf yay
}


# failsafe for if whatever reason there's already something called yay in the directory
if [ -e yay ]; then
	mkdir cgljmp.,.lhcup
	cd cgljmp.,.lhcup || exit
	installyay
	cd .. || exit
	rm -rf cgljmp.,.lhcup
else 
	installyay
fi

clear

echo -e \\n "What shell would you like to use?
Bash, the default shell. Decently customizable and universal.
Zsh, very popular and mostly compatible with bash scripts.
Fish, also very popular, is very feature-rich and pretty by default, but not bash or POSIX compliant,
	so you might face some issues with scripts
Nushell, an experimental shell that not many people use. Not POSIX compliant and difficult to get support.

All of these shells, except nushell, have an 'Oh My Shell,' which adds functionality and prettiness.
I recommend checking them out later, especially for bash and zsh, simply look up oh-my-bash or oh-my-zsh
and it should be the first result"

while true; do
	read -rp "Type the full name in all lowercase to select: " shell
	case $shell in
		"bash")
			echo -e \\n "It's already here!"\\n
			sleep 3
			break;;
		"zsh")
			echo
			$DOAS pacman -S --noconfirm zsh
			$DOAS chsh "$(who | awk '{print ($1)}')" -s /usr/bin/zsh
			break;;
		"fish") 
			echo
			$DOAS pacman -S --noconfirm fish
			$DOAS mkdir -p /usr/local/bin
			$DOAS cp fishlogin /usr/local/bin/fishlogin 
			$DOAS chmod +x /usr/local/bin/fishlogin
			$DOAS sh -c 'echo "/usr/local/bin/fishlogin" >> /etc/shells'
			$DOAS chsh "$(who | awk '{print ($1)}')" -s '/usr/local/bin/fishlogin'
			break;;
		"nushell")
			echo
			$DOAS pacman -S --noconfirm nushell
			$DOAS mkdir -p /usr/local/bin
			$DOAS cp nushell-login /usr/local/bin/nushell-login 
			$DOAS chmod +x /usr/local/bin/nushell-login
			$DOAS sh -c 'echo "/usr/local/bin/nushell-login" >> /etc/shells'
			$DOAS chsh "$(who | awk '{print ($1)}')" -s '/usr/local/bin/nushell-login'
			break;;
	esac
done

clear

echo -e \\n"Installing quality of life tools/apps"\\n
sleep 1
yay --noconfirm -S pamac-flatpak reflector-simple gparted man-db w3m lynx feh vlc wget curl htop

clear

echo -e \\n"What web browser do you want to use?
Google-Chrome
Chromium, the core of Google Chrome, with less integrations.
Ungoogled-chromium, even less Google, made to be as usable as can be without anything google-related.
Firefox
Waterfox, a privacy-focused Firefox fork that removes the light telemetry that Mozilla adds.
Librewolf, an even more privacy-focused Firefox fork, and may make certain sites annoying to use without setup."\\n

while true; do
	read -rp "Type the full name in all lowercase, including hyphens, to select: ie 'google-chrome' " browser
	case $browser in
		"google-chrome")
			echo
			yay -S --noconfirm google-chrome
			break;;
		"chromium")
			echo
			$DOAS pacman -S --noconfirm chromium
			break;;
		"ungoogled-chromium")
			echo
			yay -S --noconfirm ungoogled-chromium
			break;;
		"firefox")
			echo
			$DOAS pacman -S --noconfirm firefox
			break;;
		"waterfox")
			echo
			yay --noconfirm -S waterfox-bin
			break;;
		"librewolf")
			echo
			yay --noconfirm -S librewolf-bin
			break;;
	esac
done

clear

echo -e \\n"Do you want to install LibreOffice? (Open-source alternative to Microsoft Office, Word, Excel, etc.) Not recommended if you're low on storage"\\n
while true;do
	read -rp "(y/n)" office
	case $office in
		[yY] )
			$DOAS pacman -S --noconfirm libreoffice-fresh
			break;;
		[nN] )
			break;;
	esac
done

clear

echo -e \\n"Do you want to install retroarch?"\\n
while true; do
	read -rp "(y/n)" retroarch
	case $retroarch in
		[yY] )
			$DOAS pacman -S --noconfirm retroarch retroarch-assets-xmb retroarch-assets-ozone
			$editor retroarch-cores
			$DOAS pacman -S --noconfirm < retroarch-cores
			break;;
		[nN] )
			break;;
	esac
done
clear
echo "If you want other emulators, write \"yay EMULATOR\" and it will automatically search it for you."
read -rp "
Press enter to exit and automatically delete the script or press ctrl+c to cancel and keep it."

cd .. || exit
if [ -d archinstall ]; then
	rm -rf archinstall
else
	echo "It's already gone???"
fi
