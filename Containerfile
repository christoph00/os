FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as os-main


ADD ./files/ /




RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm*; \
    dnf -y install authselect bcache-tools nu firewalld wireguard-tools git-core htop just fedora-repos-ostree fedora-repos-archive vim-minimal util-linux usbutils \
    systemd-oomd-defaults systemd-resolved qemu-guest-agent NetworkManager-bluetooth udisks2


RUN chmod +x /scripts/*.sh;

RUN /scripts/homed-selinux.sh;

RUN dnf clean all; \
    rm -rf /tmp/*; \
    rm -rf /scripts

CMD ["/sbin/init"]

LABEL containers.bootc  1

FROM os-main as os-init

RUN groupadd --force wheel && \
    chmod u+w /etc/sudoers && \
    echo "%wheel   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create devops user
RUN useradd -G init && \
    usermod --password $1$jB5apJnm$c/rJxRig6B2xFe6WmKr610 init


ENV HOME /home/init

LABEL containers.bootc  1
    

FROM os-main as os-desktop


RUN dnf -y install xdg-desktop-portal-kde plasma-desktop sddm sddm-kcm sddm-breeze fedora-release-kinoite konsole langpacks-en flatpak-kcm distrobox \
        zram-generator-defaults kf6-networkmanager-qt NetworkManager-wifi fedora-workstation-repositories default-fonts-core-mono default-fonts-core-sans systemd-container flatpak xdg-desktop-portal \
        plasma-nm plasma-pa plasma-systemmonitor plasma-print-manager plasma-vault plasma-workspace-wayland sddm-wayland-plasma signon-kwallet-extension spectacle  xwaylandvideobridge kaccounts-providers polkit-kde \
        openvswitch jq

ADD ./scripts/extra-packages.nu /tmp/extra-packages.nu


RUN chmod +x /tmp/extra-packages.nu; \
    /tmp/extra-packages.nu


RUN LATEST_URL=$(curl -sL https://api.github.com/repos/cloud-hypervisor/cloud-hypervisor/releases/latest | jq -r '.assets[] | select(.name? | match(".*cloud-hypervisor$")) | .browser_download_url') \
    curl -sL -o /usr/bin/cloud-hypervisor ${LATEST_URL}; \
    chmod +x /usr/bin/cloud-hypervisor; \
    setcap cap_net_admin+ep /usr/bin/cloud-hypervisor

# CH Remote
RUN LATEST_REMOTE_URL=$(curl -sL https://api.github.com/repos/cloud-hypervisor/cloud-hypervisor/releases/latest | jq -r '.assets[] | select(.name? | match(".*ch-remote$")) | .browser_download_url') \
    curl -sL -o /usr/bin/ch-remote ${LATEST_REMOTE_URL}; \
    chmod +x /usr/bin/ch-remote

RUN systemctl set-default graphical.target


RUN dnf -y clean all; rm -rf /tmp/*

LABEL containers.bootc  1
