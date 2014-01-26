#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

PUSH=$1
BSPEED=$2
: ${PUSH:=false}
: ${BSPEED:="10"}
BVARIANT=$3

source build/envsetup.sh
#source jet/credentials.sh

echo "Setting Lunch Menu to ${BVARIANT} Bitches!!!"
lunch oct_${BVARIANT}-userdebug

## Clean Up Previous Builds as well as old md5sum files
make installclean && rm -rf out/target/product/*/*md5sum

## Current Build Date
BDATE=`date +%m-%d`
COPY_DIR=~/Desktop/Copy/AndroidDev/ROMz/OctOS

if [ $1 = "y" ]; then
PUSH=true
else
PUSH=false
fi

if [ ! -d "${COPY_DIR}/${BDATE}" ]; then
	echo "Creating directory for ${COPY_DIR}/${BDATE}"
	mkdir -p ${COPY_DIR}/${BDATE}
fi

echo "Starting brunch with ${BSPEED}.5 jigawatts threads for ${COPY_DIR}"
if ${PUSH}; then
echo "Pushing to Remote after fukin build!"
fi
# Build command
brunch ${BVARIANT} -j${BSPEED}
find ${OUT} '(' -name 'Oct*' -size +150000 ')' -print0 |
        xargs --null md5sum |
        while read CHECKSUM FILENAME
        do
		if [ ${FILENAME} == "-" ]; then
			echo "Fuked Up Build"
		else
			if ! $PUSH; then
			echo "Moving to Copybox G..."
                	cp ${FILENAME} ${COPY_DIR}/${BDATE}/${FILENAME##*/}
                	cp "${FILENAME}.md5sum" ${COPY_DIR}/${BDATE}/${FILENAME##*/}.md5
			fi
	        fi
        done

