ARG BASEIMAGE=docker.io/library/ubuntu:24.04

FROM ${BASEIMAGE} AS tex

RUN apt-get update -y && apt-get install -y --no-install-recommends curl ca-certificates gnupg perl-doc

ARG TEXLIVE=2025
ARG TEXLIVEMIRROR=https://mirror.ctan.org/sites/ctan.org/systems/texlive/tlnet

COPY ./install.profile ./provision-tl.sh /tmp/
RUN --mount=type=cache,target=/usr/local/texlive/${TEXLIVE}/tlpkg/backups bash /tmp/provision-tl.sh

FROM ${BASEIMAGE}

RUN userdel -rf ubuntu && useradd -mU -s /bin/bash -u 1000 lina 

COPY ./provision-apt.sh /tmp
RUN --mount=type=cache,target=/var/cache/apt/archives \
  bash /tmp/provision-apt.sh
RUN echo '#1000 ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/nopasswd && chmod 0440 /etc/sudoers.d/nopasswd

COPY ./provision-nix.sh /tmp
RUN bash /tmp/provision-nix.sh 

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/bin/

COPY --from=tex /usr/local/texlive/ /usr/local/
ENV PATH=/usr/local/texlive/${TEXLIVE}/bin/x86_64-linux:$PATH

