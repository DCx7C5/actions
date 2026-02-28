# .github/actions/run-in-arch/Dockerfile
FROM archlinux:base-devel

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      git base-devel sudo namcap arch-install-scripts \
      gnupg openssh wget curl jq moreutils && \
    pacman -Scc --noconfirm

# Create non-root builder user (required for makepkg)
RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/builder && \
    echo 'MAKEFLAGS="-j$(nproc)"' >> /etc/makepkg.conf && \
    echo 'PKGEXT=".pkg.tar.zst"' >> /etc/makepkg.conf

USER builder
WORKDIR /github/workspace

# Create a persistent GPG directory that will be mounted from host
RUN mkdir -p /home/builder/.gnupg

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN sudo chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]