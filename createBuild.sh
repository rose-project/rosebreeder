#!/bin/bash

usage()
{
cat << EOF

Usage: $0 [p:h] <BUILD_DIR>
    BUILD_DIR   build directory folder

    optional options:
        -h          show this help message
        -p Project  valid projects are "meta-rose" [default] and "meta-villa"
EOF

exit -1
}

BUILD_DIR=

CONF=meta-rose
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

if [[ ! -d ${REPO_DIR}/${CONF}/conf ]]; then
    echo "Template configuration not found ${CONF}"
    exit -2;
fi

TPL_CONF="${CONF}/conf"


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

cp -f templates/makeImage.sh ${BUILD_DIR}/makeImage

echo "Build dir created"
echo "to start work do the following steps:"
echo ""
echo "cd ${BUILD_DIR}"
echo ". ./init-env"
