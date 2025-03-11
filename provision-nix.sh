#!/bin/bash
set -euxo pipefail
curl -fsSL -o /tmp/nix-installer 'https://github.com/DeterminateSystems/nix-installer/releases/latest/download/nix-installer-x86_64-linux'
cleanup_installer() {
	rm -v /tmp/nix-installer
}
trap cleanup_installer EXIT
chmod +x /tmp/nix-installer
/tmp/nix-installer install linux \
	--no-confirm \
	--init none \
	--extra-conf "sandbox = false" \
	--extra-conf "extra-trusted-users = 1000"
