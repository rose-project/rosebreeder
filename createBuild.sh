#!/bin/bash

usage()
{
cat << EOF

Usage: $0 [p:h] <BUILD_DIR>
    BUILD_DIR   build directory folder

    optional options:
        -h          show this help message
        -p Project  valid projects are "rose" [default] and "villa"
EOF

exit -1
}

BUILD_DIR=

CONF=rose
TPL_CONF=

REPO_DIR=$(dirname $(readlink -e $(pwd)/../poky/oe-init-build-env))

if [[ ! -e ${REPO_DIR}/oe-init-build-env ]];then
	echo "$0 must be called direct"
	exit -1
fi

while getopts 'p:h' OPTION ; do
  case "$OPTION" in
    p)   CONF=$OPTARG;;
    h)  usage;;
    *)  echo "Invalid option: -$OPTARG" >&2; usage;;
  esac
done

shift $((OPTIND - 1))
if [[ $# != 1 ]]; then
    echo "No build dir given or additional parameter"
    usage
fi

BUILD_DIR=$1

if [[ "${CONF,,}" == "rose" ]]; then
    TPL_CONF="meta-rose/conf"
elif [[ "${CONF,,}" == "villa" ]]; then
    TPL_CONF="meta-villa/conf"
else
    echo "Unknown project ${CONF}"
    exit -2;
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
