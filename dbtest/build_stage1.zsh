#!/usr/bin/env zsh
cd "${0:h}/stage1" || exit 1

# download and install apt packages and then clone git repo
docker build -f Dockerfile_bionic -t lwerner/docker_debuild:bionic-staged $(pwd) \
	&& docker push lwerner/docker_debuild:bionic-staged

docker build -f Dockerfile_disco -t lwerner/docker_debuild:disco-staged $(pwd) \
	&& docker push lwerner/docker_debuild:disco-staged

docker build -f Dockerfile_stable -t lwerner/docker_debuild:stable-staged $(pwd) \
	&& docker push lwerner/docker_debuild:stable-staged

docker build -f Dockerfile_testing -t lwerner/docker_debuild:testing-staged $(pwd) \
	&& docker push lwerner/docker_debuild:testing-staged


