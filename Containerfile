FROM docker.io/library/ubuntu:24.04 AS base

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

# ARG QUARTO=1.6.42

# ADD https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO}/quarto-${QUARTO}-linux-amd64.deb /tmp/quarto.deb
RUN userdel -rf ubuntu && useradd -mU -s /bin/bash -u 1000 lina 
COPY ./provision-apt.sh /tmp
RUN --mount=type=cache,target=/var/cache/apt/archives \
  bash /tmp/provision-apt.sh
RUN echo '#1000 ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopasswd && chmod 0440 /etc/sudoers.d/nopasswd

COPY ./provision-nix.sh /tmp
RUN bash /tmp/provision-nix.sh 

FROM base AS tex

ARG TEXLIVE=2025
ARG TEXLIVEMIRROR=https://mirror.ox.ac.uk/sites/ctan.org/systems/texlive/tlnet

COPY ./install.profile ./provision-tl.sh /tmp/
RUN --mount=type=cache,target=/usr/local/texlive/${TEXLIVE}/tlpkg/backups bash /tmp/provision-tl.sh
ENV PATH=/usr/local/texlive/${TEXLIVE}/bin/x86_64-linux:$PATH

