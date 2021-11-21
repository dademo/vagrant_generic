#!/bin/bash

## FROM: https://github.com/vagrant-libvirt/vagrant-libvirt#additional-notes-for-fedora-and-similar-linux-distributions

set -e
set -o xtrace

cd "$(dirname "$0")/resources"
if [ -d ./krb5-libs ]; then
    rm -rf ./krb5-libs
fi
if [ -d ./centos-git-common ]; then
    rm -rf ./centos-git-common
fi
if [ -d ./krb5 ]; then
    rm -rf ./krb5
fi
# Fedora
dnf download --source krb5-libs

# centos 8 stream, doesn't provide source RPMs, so you need to download like so
git clone https://git.centos.org/centos-git-common
# centos-git-common needs its tools in PATH
export PATH=$(readlink -f ./centos-git-common):$PATH
git clone https://git.centos.org/rpms/krb5
cd krb5
git checkout --force imports/c8s/krb5-1.18.2-8.el8
into_srpm.sh -d c8s
cd SRPMS

# common commands (make sure to adjust verison accordingly)
rpm2cpio krb5-1.18.2-*.src.rpm | cpio -imdV
tar xf krb5-1.18.2.tar.gz
cd krb5-1.18.2/src
./configure
make
sudo cp -P lib/crypto/libk5crypto.* /opt/vagrant/embedded/lib64/