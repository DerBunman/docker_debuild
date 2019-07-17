#!/usr/bin/env zsh
zmodload zsh/parameter
cd "$HOME" || exit

#git clone --recursive https://github.com/DerBunman/DieBenutzerumgebung ~/.repos/dotfiles

cd ~/.repos/dotfiles
git pull --recurse-submodules

# when the docker plugin is enabled the build blocks there
sed -i 's/docker//' ~/.repos/dotfiles/packages/zsh/zshrc

# enable all host flags
mkdir -p ~/.config/dotfiles/dotfiles/host_flags/
echo "has_x11 has_root install_packages assume_yes" > \
	~/.config/dotfiles/dotfiles/host_flags/checked

#apt --yes install python apt-utils neofetch

xvfb-run -n 99 \
	--server-args="-screen 0 1360x768x16" \
	--auth-file ~/.Xauthority \
	xterm -e "/install.zsh" #&

#sleep 2 && tail -f /dfp_log.txt &
#
#while (( ${#jobstates} )); do
#	sleep 5
#	echo JOBS ${jobstates}
#	img=1.png;
#	DISPLAY=:99 scrot $img || exit
#	curl -s -X POST -F "image=@$img" https://doublefun.net/media/x.php
#done
#
