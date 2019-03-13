#!/usr/bin/env zsh
seconds_script_start=$(date +%s)
action=$1
[[ $# -gt 0 ]] && shift
FIGLET=$(which figlet)

function info() {
	print -P "%F{green}%B[INFO]%b%f %F{white}${*}%f"
}

function error() {
	print -P "%F{red}%B[ERROR]%b%f %F{white}${*}%f"
}

typeset -A opts
opts=(
	--target debian:testing
	--emtry-point debian:testing
)
zparseopts -D -K -A opts -- \
	-target: \
	-image-name: \
	-container-name: \
	-mountpoint-home: \
	-mountpoint-src: \
	-entrypoint: \
	-rm-container:: \
	-skip-info::

#print -l "${(@kv)opts}"

typeset -A config
config=(
	target ${opts[--target]}
	image_name ${opts[--image-name]=debuild_${opts[--target]}}
	container_name ${opts[--container-name]=debuild_${opts[--target]/:/-}}
	mountpoint_home ${opts[--mountpoint-home]=$(pwd)/data/volumes/home}
	mountpoint_src ${opts[--mountpoint-src]=$(pwd)/data/volumes/src}
	rm_container ${opts[--rm-container]=false}
	skip_info ${opts[--skip-info]=false}
	entrypoint ${opts[--entryoint]=false}
)
typeset -A config_descriptions
config_descriptions=(
	target 'target debian/ubuntu release'
	image_name 'human readable name'
	container_name 'human readable name'
	mountpoint_home 'homedir which contains .gnupg and other configs'
	mountpoint_src 'src dir, all subdirs will be respected as one project'
	rm_container 'remove container after shutdown'
	skip_info 'donet show the configuration and the banner'
	entrypoint 'false = no change | everything else will be executed'
)
[[ "${DEBUG}" != "" ]] && setopt verbose

[[ ${opts[--skip-info]} != "true" ]] && {
	print -P "%B%F{white}"
	echo $0 | $FIGLET
	print -P "%b%f"
	print -P "   %B%UConfiguration:%u%b\n"
	{
		for key val in ${(kv)config}; do
			echo "--${key/_/-}%${val}%${config_descriptions[${key}]}"
		done | sort
		echo ""
		echo "action: ${action}"
	} | column -e -t -s'%' | sed -e 's/^/    /'
	echo ""
}

has_error=false
[[ "${opts[--skip-info]}" != "false" ]] && [[ "${opts[--skip-info]}" != "true" ]] && {
	has_error=true
	error "illegal value ${opts[--skip-info]} for --skip-info (only true/false)"
}

[[ "${opts[--rm-container]}" != "false" ]] && [[ "${opts[--rm-container]}" != "true" ]] && {
	has_error=true
	error "illegal value ${opts[--rm-container]} for --rm-container (only true/false)"
}

info "removing gpg socket files (if they exist)"
find ${config[mountpoint_home]}/.gnupg/ -iname "S.*" -delete


[[ has_error = true ]] && exit 1

if [ "shell" = "${action}" ] || [ "run" = "${action}" ]; then
	typeset -a pre_flight_check_errors
	
	test -d "${config[mountpoint_src]}" \
		|| pre_flight_check_errors+=("$(error Directory ${config[mountpoint_src]} does not exist.)")
	test -d "${config[mountpoint_home]}" \
		|| pre_flight_check_errors+=("$(error Directory ${config[mountpoint_home]} does not exist.)")

	[[ ! -z $pre_flight_check_errors ]] && {
		for error in ${pre_flight_check_errors}; do
			echo "${error}"
		done | sort
		exit 1
	}
fi

if [ "build" = "${action}" ]; then
	#  _           _ _     _ 
	# | |__  _   _(_) | __| |
	# | '_ \| | | | | |/ _` |
	# | |_) | |_| | | | (_| |
	# |_.__/ \__,_|_|_|\__,_|
	###########################
	info "starting build of image %U${config[image_name]}%u"
	echo ""
	
	info "building Dockerfile"
	cat $(dirname $0)/Dockerfile_template | sed "s/%TARGET%/${opts[--target]}/" \
		> $(dirname $0)/Dockerfile.$$

	stdbuf -i0 -o0 -e0 \
	docker build \
		-f $(dirname $0)/Dockerfile.$$ \
		--label ${config[image_name]} \
		--tag ${config[image_name]} \
		$(pwd) \
	| sed 's/^/   * /'
	$(dirname $0)/Dockerfile_template

elif [ "shell" = "${action}" ]; then
	#      _          _ _ 
	#   ___| |__   ___| | |
	#  / __| '_ \ / _ \ | |
	#  \__ \ | | |  __/ | |
	#  |___/_| |_|\___|_|_|
	#########################
	docker run --rm -it \
		--name "${config[container_name]}" \
		--label "${config[container_name]}" \
		-v "${config[mountpoint_home]}:/build/home" \
		-v "${config[mountpoint_src]}:/build/src" \
		--entrypoint /bin/bash \
		${config[image_name]} \
		$*


elif [ "run" = "${action}" ]; then
	#  _ __ _   _ _ __
	# | '__| | | | '_ \
	# | |  | |_| | | | |
	# |_|   \__,_|_| |_|
	######################
	docker image inspect ${config[image_name]} 1> /dev/null 2>&1
	[[ $? -gt 0 ]] && {
		info "could not find image %U${config[image_name]}%u so we build it now"
		$0 build \
			--target ${config[target]} \
			--image-name ${config[image_name]} \
			--skip-info true || {
			error "building image failed"
			exit 1
		}

	}
	info "starting docker container %U${config[container_name]}%u"

	docker container inspect "${config[container_name]}" 1> /dev/null 2>&1
	if [[ $? -gt 0 ]]; then
		info "starting new container"
		docker run --rm -i \
			--name "${config[container_name]}" \
			--label "${config[container_name]}" \
			-v "${config[mountpoint_home]}:/build/home" \
			-v "${config[mountpoint_src]}:/build/src" \
			${config[image_name]}
	else
		info "%B%F{red}there is already a container named %U${config[container_name]}%u%f%b"
		print -P "\n       You can delete the container withe the following command:"
		print -P "       %{docker container rm --force ${config[container_name]}%}\n"
		print -P "       Press %B%UENTER%u%b to start the existing container or %B%UCTRL-c%u%b to abort."
		read VAR
		info "starting existing container"
		docker start -i \
			${config[container_name]}
	fi
else
	echo "please provide valid action parameter"
	echo "eg: ${0} build"
	echo "eg: ${0} run"
fi

print -P -- "- FIN -\n"
print -P -- "runtime: $(( $(date +%s)-$seconds_script_start ))sec"
