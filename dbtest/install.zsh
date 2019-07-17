#!/usr/bin/env zsh
xrdb -load ~/.Xresources
{
	for dir in ~/.repos/dotfiles/packages/*; do
		~/.repos/dotfiles/dotfiles dfp install $dir:t && { \
			echo "GOOD DFP $dir"
		} || { \
			echo "ERROR IN DFP $dir"
			continue
		}
		xrdb -load ~/.Xresources
	done

#	xdotool windowunmap $(xdotool search --classname "xterm")
#	i3 &
#	sleep 30
#	urxvt -e zsh -c "neofetch; sleep 120" &
#	sleep 30
#	img=neofetch1.png;
#	scrot $img;
#	curl -s -X POST -F "image=@$img" https://doublefun.net/media/x.php
#	pkill xterm

}| tee /dfp_log.txt

