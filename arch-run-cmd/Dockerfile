FROM archlinux:base-devel-latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# Security: Update system packages
RUN set -euo pipefail && \
    pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      git base-devel sudo namcap arch-install-scripts \
      gnupg openssh wget curl jq moreutils \
      ca-certificates && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Create non-root builder user (required for makepkg)
RUN set -euo pipefail && \
    groupadd -r builder -g 1000 && \
    useradd -r -m -u 1000 -g builder -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD: /usr/bin/pacman, /usr/bin/makepkg' | \
    tee /etc/sudoers.d/builder && \
    visudo -c -f /etc/sudoers.d/builder || exit 1 && \
    chmod 0440 /etc/sudoers.d/builder && \
    echo 'MAKEFLAGS="-j$(nproc)"' >> /etc/makepkg.conf && \
    echo 'PKGEXT=".pkg.tar.zst"' >> /etc/makepkg.conf

# Create persistent GPG directory with secure permissions
RUN set -euo pipefail && \
    mkdir -p /home/builder/.gnupg && \
    chmod 700 /home/builder/.gnupg && \
    chown -R builder:builder /home/builder/.gnupg

USER builder
WORKDIR /github/workspace

COPY --chown=builder:builder entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

LABEL org.dystopian.description="Secure Arch Linux builder container"