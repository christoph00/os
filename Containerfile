FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as os-main


ADD ./files/ /




RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm*; \
    dnf -y install authselect bfachefs-tools nu firewalld wireguard-tools git-core htop just fedora-repos-ostree fedora-repos-archive vim-minimal util-linux usbutils \
    systemd-oomd-defaults systemd-resolved qemu-guest-agent NetworkManager-bluetooth  


RUN chmod +x /scripts/*.sh;

RUN /scripts/homed-selinux.sh;

RUN dnf clean all; \
    rm -rf /tmp/*; \
    rm -rf /scripts

CMD ["/sbin/init"]

LABEL containers.bootc  1


FROM os-main as os-desktop


RUN dnf -y install xdg-desktop-portal-kde plasma-desktop sddm sddm-kcm sddm-breeze fedora-release-kinoite konsole langpacks-en flatpak-kcm distrobox \
        zram-generator-defaults kf6-networkmanager-qt NetworkManager-wifi fedora-workstation-repositories default-fonts-core-mono default-fonts-core-sans systemd-container flatpak xdg-desktop-portal \
        plasma-nm plasma-pa plasma-systemmonitor plasma-print-manager plasma-vault plasma-workspace-wayland sddm-wayland-plasma signon-kwallet-extension spectacle udisks2 xwaylandvideobridge kaccounts-providers polkit-kde

ADD ./scripts/extra-packages.nu /tmp/extra-packages.nu

RUN chmod +x /tmp/extra-packages.nu; \
    /tmp/extra-packages.nu


RUN systemctl set-default graphical.target