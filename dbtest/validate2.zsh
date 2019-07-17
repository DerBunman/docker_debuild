#!/usr/bin/env zsh
{
	#xrdb -merge ~/.Xresources
	#xdotool windowunmap $(xdotool search --classname "xterm")
	xdotool windowunmap $(xdotool search --classname "xterm")
	i3 &
	sleep 20
	i3-msg restart
	urxvt -e zsh -c "neofetch; sleep 120" &
	sleep 5
	i3-msg restart
	sleep 10
	img=neofetch1.png;
	scrot $img;
	curl -s -X POST -F "image=@$img" https://doublefun.net/media/x.php
	pkill i3

} #| tee /dfp_log.txt

