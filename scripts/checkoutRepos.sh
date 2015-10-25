#!/bin/bash


usage()
{
	APPNAME=$(basename $1)
	cat << EOF 
	usage: ${APPNAME}	[-options] <destDir>

EOF
}


while getopts "h?p" opt; do
    case "$opt" in
    h|\?)
        usage $0
        exit 0
        ;;
    v)  verbose=1
        ;;
#    f)  output_file=$OPTARG
#        ;;
    esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift


if [[ $# -ne 1 ]]; then
	echo "Error: Unknown arguments"	
	usage $0
	exit -1;
fi

DESTDIR=$1

if [[ -d ${DESTDIR} ]]; then
	echo "Warning! Destination directory does already exists!"
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

pushd $DESTBASE

git clone -b 1.26 git://git.openembedded.org/bitbake bitbake
git clone https://github.com/rose-project/meta-raspberrypi-bsp.git
git clone https://github.com/rose-project/meta-rose.git
git clone -b fido https://github.com/meta-qt5/meta-qt5.git
git clone https://github.com/rose-project/meta-villa.git

echo "TEMPLATECONF=\${TEMPLATECONF:-meta-villa/conf}" > .templateconf

popd

echo "Checkout done, have much fun!"





