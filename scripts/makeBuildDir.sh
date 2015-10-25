#!/bin/bash

if [[ $# != 1 ]]; then
	echo "usage: makeBuildDir <BUILD_DIR>"
	exit -1
fi

BUILD_DIR=$1

if [[ ! -e ./oe-init-build-env ]];then
	echo "$0 must be called direct"
	exit -1
fi

REPO_DIR=$(dirname $(readlink -e $0))

. ./oe-init-build-env ${BUILD_DIR}  > /dev/null

pushd ${BUILD_DIR}  > /dev/null

cat > init-env << EOF
#!/bin/bash

if [[ "\$BASH_SOURCE" == "\$0" ]];then
   echo "script is not sourced:"
	echo "source ./init-env"
	exit -1
fi

. ${REPO_DIR}/oe-init-build-env ${BUILD_DIR}

EOF

popd  > /dev/null

echo "Build dir created"
echo "to start work do the following steps:"
echo ""
echo "cd ${BUILD_DIR}"
echo ". ./init-env"
