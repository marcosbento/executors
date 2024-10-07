#!/usr/bin/env bash

set -e
set -x

BASE_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

BUILD_ARCH=${BUILD_ARCH:-amd64} # amd64, arm64
BUILD_TIMESTAMP=$(date -u +'%Y%m%dT%H%M%S')

if [ "${BUILD_ARCH}" == "amd64" ]; then
    CMAKE_ARCH="x86_64"
elif [ "${BUILD_ARCH}" == "arm64" ]; then
    CMAKE_ARCH="aarch64"
fi

function dockbuild_linux() {
    local kind=$1
    local tag=$2
    local dockerfile=$3

    if [ "${kind}" == "ubuntu" ]; then
        docker build --tag ${tag}__${BUILD_TIMESTAMP} --file ${dockerfile} --platform linux/${BUILD_ARCH} --build-arg CMAKE_ARCH=${CMAKE_ARCH} .
    else
        docker build --tag ${tag}__${BUILD_TIMESTAMP} --file ${dockerfile} --platform linux/${BUILD_ARCH} .
    fi
    docker tag ${tag}__${BUILD_TIMESTAMP} ${tag}

    docker push ${tag}__${BUILD_TIMESTAMP}
    docker push ${tag}
}

function dockall() {
    local namespace="marcosbento/executors"

    dockbuild_linux ubuntu "${namespace}:ubuntu_24_04__${BUILD_ARCH}" "Dockerfile.ubuntu-24.04"
    dockbuild_linux rockylinux "${namespace}:rockylinux_8_6__${BUILD_ARCH}" "Dockerfile.rockylinux-8.6"
    dockbuild_linux rockylinux "${namespace}:rockylinux_8_9__${BUILD_ARCH}" "Dockerfile.rockylinux-8.9"
    dockbuild_linux fedora "${namespace}:fedora_38__${BUILD_ARCH}" "Dockerfile.fedora-38"
    dockbuild_linux debian "${namespace}:debian_11_9__${BUILD_ARCH}" "Dockerfile.debian-11.9"
}

pushd ${BASE_DIR}

dockall

popd
