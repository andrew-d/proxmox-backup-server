FROM debian:bookworm
ARG S6_OVERLAY_VERSION=3.2.0.0

# Update apt and install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
      ca-certificates   \
      wget              \
      xz-utils          \
    && rm -rf /var/lib/apt/lists/*

# Disable pbs nag in dpkg
COPY apt-proxmox-disable-nag /usr/local/bin/
RUN echo 'DPkg::Post-Invoke { "/usr/local/bin/apt-proxmox-disable-nag"; };' > /etc/apt/apt.conf.d/no-nag-script

# Install pbs sources
RUN wget -O /etc/apt/keyrings/proxmox-release-bookworm.gpg 'https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg' && \
    echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/proxmox-release-bookworm.gpg] http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription' \
      > /etc/apt/sources.list.d/pbs.list && \
    apt-get update && \
    apt install -y --no-install-recommends proxmox-backup-server zfsutils-linux && \
    { test -f /etc/apt/sources.list.d/pbs-enterprise.list && sed -i 's/^/#/' /etc/apt/sources.list.d/pbs-enterprise.list || true ; } && \
    rm -rf /var/lib/apt/lists/*

# Install s6
RUN wget -O /tmp/s6-overlay-noarch.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
 && wget -O /tmp/s6-overlay-x86_64.tar.xz https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
 && rm -f /tmp/s6-overlay*.tar.xz

# Copy the service definitions
COPY etc /etc/

ENTRYPOINT ["/init"]
