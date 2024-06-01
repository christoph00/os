

FROM scratch as files
COPY --from=gcr.io/projectsigstore/cosign /ko-app/cosign /bin/cosign

FROM quay.io/fedora/fedora-bootc:40 as base


ADD files/wheel-sudo /etc/sudoers.d/wheel-sudo

ARG GH_USER="${GH_USER:-christoph00}"
ARG KEYS_URL="https://github.com/${GH_USER}.keys"


RUN dnf -y autoremove ntfs-3g* ntfsprogs qemu-user-static* samba-* toolbox lvm2* mdadm* \
    && dnf -y install nu firewalld wireguard-tools git-core\
    && dnf clean all \
    && rm -rf /tmp/* 


RUN adduser core -g wheel

# for test
RUN echo "root:root" | chpasswd



ADD ${KEYS_URL} /usr/etc-system/core.keys

RUN touch /etc/ssh/sshd_config.d/30-auth-system.conf; \
    mkdir -p /usr/etc-system/; \
    echo 'AuthorizedKeysFile /usr/etc-system/%u.keys .ssh/authorized_keys' >> /etc/ssh/sshd_config.d/30-auth-system.conf; \
    chown core /usr/etc-system/core.keys; \
    chmod 0600 /usr/etc-system/core.keys


CMD ["/sbin/init"]

LABEL containers.bootc  1