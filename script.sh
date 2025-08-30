#!/usr/bin/bash
if [ -f /usr/bin/sudo ]; then
	DOAS=/usr/bin/sudo
elif [ -f /usr/bin/doas ]; then
	DOAS=/usr/bin/doas
else 
	DOAS="su -c"
fi

read -rp 'This script is largely untested so run with caution. Press enter to continue anyway.'

$DOAS pacman -Syu
$DOAS pacman 
