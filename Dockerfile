FROM debian:testing

ENV GNUPGHOME=/build/home/.gnupg
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get upgrade -y \
		--allow-downgrades \
		--allow-remove-essential \
		--allow-change-held-packages \
	&& apt-get install -y \
		--allow-downgrades \
		--allow-remove-essential \
		--allow-change-held-packages \
		build-essential \
		figlet \
		dh-make \
		devscripts \
		cowbuilder \
		eatmydata \
		ccache \
		pbuilder

VOLUME /build/src
VOLUME /build/home

CMD mkdir /build
WORKDIR /build
ADD build.sh /build/build.sh
RUN chmod 755 /build/build.sh
ENTRYPOINT /build/build.sh
