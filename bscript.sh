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

echo "Setting Lunch Menu to ${BVARIANT}"
lunch carbon_${BVARIANT}-userdebug

## Clean Up Previous Builds as well as old md5sum files
make installclean && rm -rf out/target/product/*/*md5sum

## Current Build Date
BDATE=`date +%m-%d`
COPY_DIR=~/Desktop/Copy/AndroidDev/ROMz/Carbon

if [ $1 = "y" ]; then
PUSH=true
else
PUSH=false
fi

if [ ! -d "${COPY_DIR}/${BDATE}" ]; then
	echo "Creating directory for ${COPY_DIR}/${BDATE}"
	mkdir -p ${COPY_DIR}/${BDATE}
fi

echo "Starting brunch with ${BSPEED} threads for ${COPY_DIR}"
if ${PUSH}; then
echo "Pushing to Remote after build!"
fi
# Build command
brunch ${BVARIANT} -j${BSPEED}
find ${COPY_DIR} '(' -name 'CARBON-KK*' -size +150000 ')' -print0 |
        xargs --null md5sum |
        while read CHECKSUM FILENAME
        do
		if ! $PUSH; then
		echo "Moving to Copybox"
                cp ${FILENAME} ${COPY_DIR}/${BDATE}/${FILENAME##*/}
                cp "${FILENAME}.md5sum" ${COPY_DIR}/${BDATE}/${FILENAME##*/}.md5
		fi
		OTAFILE=`basename ${FILENAME} | cut -f 1 -d '.'`
		echo "Filename ${FILENAME} - OTAFILE: ${OTAFILE}"
		if ${PUSH}; then
			if [ -e ota.xml ]; then
			    echo "Cleaning old OTA manifest"
			    rm ota.xml
			fi
			echo "Pulling OTA manifest"
			wget http://www.teamoctos.com/ota.xml
			echo "Updating manifest for ${OTAFILE}"
	                sed -i "s/Oct-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-${BVARIANT}/${OTAFILE}/g" ota.xml
     			echo "Removing existing file from remote."
			ssh ${RACF}@${RHOST} "rm -rf ${ROUT}/${BVARIANT}/*.zip" < /dev/null
     			echo "Pushing new file ${OTAFILE} to remote"
                        scp ${FILENAME} ${RACF}@${RHOST}:${ROUT}/${BVARIANT}
			echo "Pushing new OTA manifest to remote"
			scp ota.xml ${RACF}@${RHOST}:public_html/ota.xml
		fi
        done

