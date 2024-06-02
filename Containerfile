

FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as os-main


ADD ./files/ /




RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm*; \
    dnf -y install authselect nu firewalld wireguard-tools git-core htop just


RUN chmod +x /scripts/*.sh; \
    /scripts/homed-selinux.sh; \
    dnf clean all; \
    rm -rf /tmp/*; \
    rm -rf /scripts


RUN systemctl enable systemd-homed;

CMD ["/sbin/init"]

LABEL containers.bootc  1


FROM os-main as os-desktop

RUN dny -y xdg-desktop-portal-kde