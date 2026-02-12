ARG PERL_RPMS="\
perl-interpreter \
perl-File-Find \
perl-File-Copy \
perl-Time-HiRes \
perl-Unicode-Normalize \
perl-sigtrap \
"

FROM quay.io/fedora/fedora-toolbox:43 AS base

FROM base AS ltex_ls_plus_extract

ARG LTEX_LS_PLUS_RELEASE=18.6.1
RUN (set -xo pipefail; \
    wget -qO- "https://github.com/ltex-plus/ltex-ls-plus/releases/download/${LTEX_LS_PLUS_RELEASE}/ltex-ls-plus-${LTEX_LS_PLUS_RELEASE}.tar.gz" | \
    tar -xzC /) && \
    mv /ltex-ls-plus-${LTEX_LS_PLUS_RELEASE} /ltex-ls-plus

FROM scratch AS ltex_ls_plus

COPY --from=ltex_ls_plus_extract /ltex-ls-plus /opt/ltex-ls-plus

FROM base AS texlive_install

RUN (set -eo pipefail; \
    curl -fL --insecure https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | \
    tar -xzC /tmp)

ARG PERL_RPMS
RUN --mount=type=cache,target=/var/lib/dnf \
    --mount=type=cache,target=/var/cache \
    dnf -y --setopt=install_weak_deps=False install ${PERL_RPMS}

RUN (\
    set -e; \
    cd /tmp/install-tl-2* && \
    TEXLIVE_INSTALL_ENV_NOCHECK=1 \
    TEXLIVE_INSTALL_NO_WELCOME=1 \
    perl ./install-tl \
    --no-gui \
    --no-continue \
    --no-src-install \
    --no-interaction \
    --paper=a4 \
    --scheme=scheme-infraonly \
)

COPY ./ctan /tmp/ctan
RUN "$(find /usr/local/texlive -maxdepth 1 -regex '.+[0-9]+')/bin/$(uname -m)-linux/tlmgr" install $(cat /tmp/ctan)

FROM scratch AS texlive

COPY --from=texlive_install /usr/local/texlive /usr/local/texlive

FROM base AS toolbox

COPY --from=ltex_ls_plus /opt/ltex-ls-plus /opt/ltex-ls-plus

COPY --from=texlive /usr/local/texlive /usr/local/texlive
RUN (\
    set -e; \
    texlive_path="$(find /usr/local/texlive/ -maxdepth 1 -regex '.+[0-9]+')/bin/$(uname -m)-linux/" && \
    echo "export PATH=\"\${PATH}:${texlive_path}\"" >> /etc/bashrc && \
    echo "Defaults secure_path = \"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${texlive_path}\"" > /etc/sudoers.d/texlive && \
    :)

ARG PERL_RPMS
RUN --mount=type=cache,target=/var/lib/dnf \
    --mount=type=cache,target=/var/cache/libdnf5 \
    --mount=type=tmpfs,target=/var/log \
    dnf -y copr enable petersen/nix && \
    dnf -y install \
    zsh \
    gcc \
    libxcrypt-compat \
    java-latest-openjdk-headless \
    ${PERL_RPMS}

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin

RUN hardlink --respect-xattrs --ignore-time --mount /usr /opt

FROM toolbox AS devcontainer

RUN useradd -mUG wheel -s /bin/bash -u 1000 -d /home/vscode vscode && \
    echo '#1000 ALL = NOPASSWD: ALL' > /etc/sudoers.d/vscode

USER 1000

# RUN (curl -fsSL https://sh.rustup.rs | \
#     sh -s -- -y --profile minimal -c rustfmt,rust-analyzer --no-modify-path)
