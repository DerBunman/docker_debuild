#!/usr/bin/env zsh
cd "$HOME" || exit

ls -lisah

xvfb-run -n 99 \
	--server-args="-screen 0 1360x768x16" \
	--auth-file ~/.Xauthority \
	xterm -e "ls -lisah; /validate2.zsh" #&

apt install --yes perceptualdiff
perceptualdiff -verbose -threshold 25000 neofetch1.png /validate.png
exit $?

#sleep 2 && tail -f /dfp_log.txt &
#
#while (( ${#jobstates} )); do
#	sleep 5
#	echo JOBS ${jobstates}
#	img=1.png;
#	DISPLAY=:99 scrot $img || exit
#	curl -s -X POST -F "image=@$img" https://doublefun.net/media/x.php
#done
