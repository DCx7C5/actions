FROM alpine:3.22 AS bootstrap

ARG USER=builder
ARG MAKE_JOBS=4

# Install minimal pacman + tools (aggressive size optimization)
RUN apk add --no-cache \
    pacman \
    curl \
    shadow \
    bash \
    zstd \
    gnupg \
    tar \
    ca-certificates \
    git \
    && rm -rf /var/cache/apk/*

RUN mkdir -p /etc/pacman.d /etc/pacman.d/gnupg /usr/share/pacman/keyrings /rootfs/var/lib/pacman \
    && printf '%s\n' \
   '[options]' \
   'Architecture = auto' \
   'ParallelDownloads = 8' \
   'SigLevel = Required DatabaseOptional' \
   'LocalFileSigLevel = Optional' \
   '' \
   '[core]' \
   'Include = /etc/pacman.d/mirrorlist' \
   '' \
   '[extra]' \
   'Include = /etc/pacman.d/mirrorlist' \
   '' \
   '[multilib]' \
   'Include = /etc/pacman.d/mirrorlist' \
   > /etc/pacman.conf \
    && printf '%s\n' \
       'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
       > /etc/pacman.d/mirrorlist \
    && curl -fsSL https://archlinux.org/packages/core/any/archlinux-keyring/download/ -o /tmp/archlinux-keyring.pkg.tar.zst \
    && zstd -dc /tmp/archlinux-keyring.pkg.tar.zst | tar -xf - -C /tmp \
    && cp /tmp/usr/share/pacman/keyrings/archlinux* /usr/share/pacman/keyrings/ \
    && chmod 755 /etc/pacman.d/gnupg \
    && pacman-key --init \
    && pacman-key --populate archlinux \
    && mkdir -p /rootfs/etc/pacman.d \
    && cp /etc/pacman.conf /rootfs/etc/pacman.conf \
    && cp /etc/pacman.d/mirrorlist /rootfs/etc/pacman.d/mirrorlist

RUN mkdir -p /rootfs/dev /rootfs/proc /rootfs/sys /rootfs/run \
    && mknod -m 666 /rootfs/dev/null c 1 3 2>/dev/null || true \
    && mknod -m 666 /rootfs/dev/zero c 1 5 2>/dev/null || true \
    && mknod -m 666 /rootfs/dev/random c 1 8 2>/dev/null || true \
    && mknod -m 666 /rootfs/dev/urandom c 1 9 2>/dev/null || true \
    && mount --bind /proc /rootfs/proc 2>/dev/null || true \
    && mount --bind /sys /rootfs/sys 2>/dev/null || true \
    && pacman -Sy --noconfirm --root /rootfs --cachedir /var/cache/pacman/pkg \
    && pacman -S --noconfirm --needed \
       --root /rootfs \
       --cachedir /var/cache/pacman/pkg \
       base base-devel git gnupg curl ca-certificates mold ccache iptables-nft \
    && rm -rf /tmp/archlinux-keyring.pkg.tar.zst /tmp/usr \
              /rootfs/var/cache/pacman/pkg/* \
              /rootfs/var/lib/pacman/sync/* \
              /rootfs/usr/share/man/* \
              /rootfs/usr/share/doc/* \
              /rootfs/boot/* \
              /rootfs/var/log/* \
              /rootfs/etc/pacman.conf.pacnew \
              /rootfs/etc/pacman.d/mirrorlist.pacnew 2>/dev/null || true \
    && find /rootfs -type f \( -name "*.a" -o -name "*.la" -o -name "*.go" \) -delete 2>/dev/null || true \
    && find /rootfs -type d -empty -delete 2>/dev/null || true \
    && umount /rootfs/proc 2>/dev/null || true \
    && umount /rootfs/sys 2>/dev/null || true

# Setup user & sudo (no dbus needed in minimal container)
RUN groupadd -R /rootfs builder 2>/dev/null || true \
  && useradd -R /rootfs -m -u 1000 -g builder -s /bin/bash builder 2>/dev/null || true \
  && mkdir -p /rootfs/etc/sudoers.d \
  && echo "builder ALL=(ALL) NOPASSWD: ALL" > "/rootfs/etc/sudoers.d/builder-nopasswd" \
  && chmod 0440 "/rootfs/etc/sudoers.d/builder-nopasswd" 2>/dev/null || true

RUN cat <<EOF >> /rootfs/etc/bash.bashrc
alias ls="ls --color=auto "
export LANG=C.UTF-8
export TERM=xterm-256color
export MAKEFLAGS="-j$(nproc)"
export CCACHE_DIR=/home/builder/.ccache
force_color_prompt=yes
export PS1='\[\033[1;32m\]\u\[\033[1;37m\]@\[\033[1;36m\]\h\[\033[00m\]:\[\033[1;34m\]\w\[\033[00m\]\$ '
EOF

# Create cache directories with correct ownership
RUN mkdir -p /rootfs/home/builder/.ccache /rootfs/home/builder/.gnupg /rootfs/home/builder/.cache \
  && chown -R 1000:1000 /rootfs/home/builder/.ccache \
                        /rootfs/home/builder/.gnupg \
                        /rootfs/home/builder/.cache \
  && chmod 700 /rootfs/home/builder/.gnupg \
  && chmod 700 /rootfs/home/builder/.ccache

# Optimize makepkg.conf for container builds
RUN cat <<'MAKEPKG' >> /rootfs/etc/makepkg.conf

# ===== Container Optimization =====
MAKEFLAGS="-j$(nproc)"
CCACHE_DIR="/github/workspace/.ccache"
CCACHE_MAXSIZE="1G"

# Aggressive size optimization
BUILDENV=(!distcc !color !ccache !check !sign !debug)
OPTIONS=(!strip !docs !libtool !staticlibs !emptydirs !zipman !purge !debug)

PACKAGER="${PACKAGER:-Unknown Packager <builder@container>}"
MAKEPKG

# Copy entrypoint with secure permissions
COPY --chmod=755 --chown=1000:1000 entrypoint.sh /rootfs/entrypoint.sh


FROM scratch AS arch_minimal

ARG USER=builder
ARG BUILD_DATE
ARG VCS_REF

ENV USER=${USER} \
    LANG=C.UTF-8 \
    TERM=xterm-256color \
    MAKEFLAGS="-j4" \
    CCACHE_DIR=/home/${USER}/.ccache \
    PATH=/home/${USER}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SHELL=/bin/bash

COPY --from=bootstrap /rootfs/ /

WORKDIR /github/workspace

USER ${USER}

# Comprehensive labels for Docker metadata and CI tracking
LABEL org.opencontainers.image.title="Dystopian AUR Build Environment" \
      org.opencontainers.image.description="Minimal Arch Linux environment optimized for AUR package building with makepkg in GitHub Actions" \
      org.opencontainers.image.vendor="DCx7c5" \
      org.opencontainers.image.authors="DCx7c5 <dcxdevelopment@protonmail.com>" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      net.dcxdev.dystopian.purpose="aur-builder" \
      net.dcxdev.dystopian.base="archlinux" \
      net.dcxdev.dystopian.security="nonroot,minimal,hardened" \
      net.dcxdev.dystopian.ci="github-actions"

ENTRYPOINT ["/entrypoint.sh"]
