FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as os-main


ADD ./files/ /




RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm*; \
    dnf -y install authselect nu firewalld wireguard-tools git-core htop just fedora-repos-ostree fedora-repos-archive


RUN chmod +x /scripts/*.sh;

RUN /scripts/homed-selinux.sh;

RUN dnf clean all; \
    rm -rf /tmp/*; \
    rm -rf /scripts

CMD ["/sbin/init"]

LABEL containers.bootc  1


FROM os-main as os-desktop

RUN dnf -y install xdg-desktop-portal-kde plasma-desktop sddm sddm-kcm fedora-release-kinoite langpacks-en flatpak-kcm distrobox

RUN systemctl set-default graphical.target