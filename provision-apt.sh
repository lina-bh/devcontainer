#!/bin/bash
set -euxo pipefail
export DEBIAN_FRONTEND=noninteractive
mv -v /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean.save
restore_docker_clean() {
  mv -v /etc/apt/docker-clean.save /etc/apt/apt.conf.d/docker-clean
}
trap restore_docker_clean EXIT
yes | unminimize || :
apt-get install --no-install-recommends --fix-broken -y \
	ca-certificates \
	curl \
	build-essential \
	cmake \
	ninja-build \
	qt6-tools-dev \
	qt6-svg-dev \
	sudo \
	less \
	git \
	gnupg \
	man-db \
	podman-docker \
	openssh-client \
	fish \
	;
