default_platform := "amd64"
build image arch=default_platform:
    podman build -t localhost/{{image}}:latest \
        --platform linux/{{arch}} \
        -f ./{{image}}/Containerfile \
        ./{{image}}

build-qcow2 image arch=default_platform:
    mkdir -p .osbuild/{{image}}/output
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --platform linux/{{arch}} \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --chown 1000:1000 \
            --type qcow2 --rootfs ext4 \
            --local localhost/{{image}}:latest

build-raw image:
    mkdir -p .osbuild/{{image}}/output
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --chown 1000:1000 \
            --type raw --rootfs ext4 \
            --local localhost/{{image}}:latest

build-vmdk image:
    mkdir -p .osbuild/{{image}}/output
    podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v $(pwd)/.osbuild/config.toml:/config.toml \
        -v $(pwd)/.osbuild/{{image}}/output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v osbuild-store:/store \
        -v dnf-cache:/rpmmd \
        quay.io/centos-bootc/bootc-image-builder:latest \
            --type vmdk --rootfs ext4 \
            --chown 1000:1000 \
            --local localhost/{{image}}:latest