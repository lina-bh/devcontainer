#!/bin/bash
set -euxo pipefail
shopt -s globstar
cd /tmp
curl -fsSL --remote-name-all "$TEXLIVEMIRROR"'/install-tl-unx.tar.gz'{,.sha512,.sha512.asc}
gpgdir="$(mktemp -d)"
cleanup_gpgdir() {
  rm -rfv "$gpgdir"
}
trap cleanup_gpgdir EXIT
gpg --home "$gpgdir" --recv-key 0D5E5D9106BAB6BC 
gpg --home "$gpgdir" --verify install-tl-unx.tar.gz.sha512.asc install-tl-unx.tar.gz.sha512
sha512sum --check install-tl-unx.tar.gz.sha512
tar -xvzf install-tl-unx.tar.gz
cd "$(find /tmp -depth -maxdepth 1 -type d -regextype sed -regex '/tmp/install-tl-'"$TEXLIVE"'[0-9]\{4\}$')"
env TEXLIVE_INSTALL_ENV_NOCHECK=1 perl ./install-tl --profile /tmp/install.profile --location "$TEXLIVEMIRROR"
cd /tmp
cleanup_installer() {
	rm -rfv /tmp/install-tl-*
}
trap cleanup_installer EXIT
/usr/local/texlive/**/bin/**/tlmgr install collection-latex latexmk latexindent texcount
/usr/local/texlive/**/bin/**/tlmgr option autobackup 0
