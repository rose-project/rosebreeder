#!/bin/bash

# TODO parameter parsing for debugging, primary/recovery images, another wic output dir

WIC_TEMPLATE="rosebasic-gpt"
PRIMARY_IMAGE="rose-image-minimal"
RECOVERY_IMAGE="rose-image-minimal"

# source environment, to ensure vars are set
. ./init-env > /dev/null

# get ROOTFS directory e.g. <YOCTO_BUILD>/tmp/deploy/images/<ARCH_DIR>/
BUILD_DIR=$(dirname $(bitbake -e rose-image-minimal | awk -F ' *= *' '$1=="ROOTFS"{gsub(/'\"'/, "", $2); print $2}'))

wic create ${WIC_TEMPLATE} -e ${PRIMARY_IMAGE} \
	--rootfs-dir rootfs_prim=${PRIMARY_IMAGE} \
	--rootfs-dir rootfs_rec=${RECOVERY_IMAGE} \
	--outdir=${BUILD_DIR} \
	-DD
