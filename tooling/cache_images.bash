#!/bin/bash
CACHE_IMAGES=(
    'generic/fedora34'
    'generic/fedora35'
    'generic/debian11'
    'generic/centos8'
    'almalinux/8'
    'generic/rocky8'
    'generic/ubuntu2004'
)

PROVIDERS=(
    'libvirt'
)

echo "Starting"

for IMAGE in "${CACHE_IMAGES[@]}"; do
    for PROVIDER in "${PROVIDERS[@]}"; do
        echo "==> Getting image '${IMAGE}' for provider '${PROVIDER}'"
        vagrant box add --provider "${PROVIDER}" "${IMAGE}" || true
    done
done

echo "Done"