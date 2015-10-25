#!/bin/bash
SCRIPTNAME=$(basename $0)
SCRIPTDIR=$(dirname $(readlink -e $0))

PROJECT="rose-base"
projectList=("villa-os" ${PROJECT})

usage()
{
	cat << EOF 
	usage: ${SCRIPTNAME}	[-options] <destDir>
			-p <PROJECT>	
			-? -h 			show this help message
EOF
}



while getopts "h?p:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    p)  PROJECT=${OPTARG,,}
        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift


if [[ $# -ne 1 ]]; then
	echo "Error: Unknown arguments"	
	usage
	exit -1;
fi

if [[ ! -z ${PROJECT} ]];then
	match=$(echo "${projectList[@]:0}" | grep -o $PROJECT)
	if [[ -z $match ]]; then
		echo "Unknown Project: $PROJECT"
		echo "These are available: ${projectList}"
		exit -1
	fi
fi

DESTDIR=$(readlink -m $1)

if [[ -d ${DESTDIR} ]]; then
	echo "Warning! Destination directory does already exist [${DESTDIR}]!"
	echo -n "Proceed? [N/y]: "
	read overwrite
	overwrite=${overwrite,,}
	if [[ "x${overwrite}" = "xy" ]]; then
		# TODO some actions needed ?
		echo "Overwriting files"
	else
		echo "Abort script execution"
		exit 0	
	fi
fi

mkdir -p ${DESTDIR}

cd ${DESTDIR}/../
DESTBASE=$(basename ${DESTDIR})

git clone -b fido git://git.openembedded.org/openembedded-core $DESTBASE

pushd $DESTBASE > /dev/null

git clone -b 1.26 git://git.openembedded.org/bitbake bitbake
git clone https://github.com/rose-project/meta-raspberrypi-bsp.git
git clone https://github.com/rose-project/meta-rose.git

case ${PROJECT} in
	"villa-os" )
		git clone -b fido https://github.com/meta-qt5/meta-qt5.git
		git clone https://github.com/rose-project/meta-villa.git
		echo "TEMPLATECONF=\${TEMPLATECONF:-meta-villa/conf}" > .templateconf
		;;
	"rose-base" )
		echo "TEMPLATECONF=\${TEMPLATECONF:-meta-rose/conf}" > .templateconf
		;;
	*)
		echo "Warning! Unknown Project!" 
		;;		
esac

popd > /dev/null

cp -f ${SCRIPTDIR}/makeBuildDir.sh ${DESTDIR}/makeBuildDir
chmod +x ${DESTDIR}/makeBuildDir

echo "Checkout done, have much fun!"





