#!/bin/bash
set -euxo pipefail
: "${FLUX_RELEASE:=2.7.5}"
arch=
case $(uname -m) in
  x86_64) arch=amd64;;
  aarch64) arch=arm64;;
esac
curl -fL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_RELEASE}/flux_${FLUX_RELEASE}_linux_${arch}.tar.gz" | tar -xzC /
