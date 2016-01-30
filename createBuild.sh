#!/bin/bash

if [[ $# != 1 ]]; then
	echo "usage: createBuild <BUILD_DIR>"
	exit -1
fi

BUILD_DIR=$1

TPL_CONF="meta-rose/conf"

REPO_DIR=$(dirname $(readlink -e $(pwd)/../poky/oe-init-build-env))

if [[ ! -e ${REPO_DIR}/oe-init-build-env ]];then
	echo "$0 must be called direct"
	exit -1
fi

pushd ${REPO_DIR}  > /dev/null
TEMPLATECONF=${TPL_CONF} . $REPO_DIR/oe-init-build-env ${BUILD_DIR}  > /dev/null
popd > /dev/null

TPL_SRC=${REPO_DIR}/oe-init-build-env
TPL_BUILD=${BUILD_DIR}

while read -r line
do
    line=${line//\"/\\\"}
    line=${line//\`/\\\`}
    line=${line//\$/\\\$}
    line=${line//\\\${/\${}
    eval "echo \"$line\""; 
done < templates/init-env >  ${BUILD_DIR}/init-env
 
echo "Build dir created"
echo "to start work do the following steps:"
echo ""
echo "cd ${BUILD_DIR}"
echo ". ./init-env"
