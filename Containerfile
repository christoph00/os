

FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as base


ADD ./files/ /




RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm*; \
    dnf -y install authselect nu firewalld wireguard-tools git-core htop


RUN chmod +x /scripts/*.sh; \
    /scripts/homed-selinux.sh; \
    dnf clean all; \
    rm -rf /tmp/*; \
    rm -rf /scripts



CMD ["/sbin/init"]

LABEL containers.bootc  1