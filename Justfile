default_platform := "amd64"
build image arch=default_platform:
    sudo podman build -t localhost/{{image}}:latest \
        --platform linux/{{arch}} \
        --target {{image}} \
        -f ./Containerfile

build-qcow2 image arch=default_platform:
    mkdir -p output/{{image}}
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --platform linux/{{arch}} \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/data/config.toml:/config.toml \
        -v $(pwd)/output/{{image}}:/output -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --chown 1000:1000 \
            --type qcow2 --rootfs xfs \
            --local localhost/{{image}}:latest

build-raw image:
    mkdir -p output/{{image}}
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/data/config.toml:/config.toml \
        -v $(pwd)/output/{{image}}:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --chown 1000:1000 \
            --type raw --rootfs xfs \
            --local localhost/{{image}}:latest

build-vmdk image:
    mkdir -p output/{{image}}
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/data/config.toml:/config.toml \
        -v $(pwd)/output/{{image}}:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type vmdk --rootfs xfs \
            --chown 1000:1000 \
            --local localhost/{{image}}:latest