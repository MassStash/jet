#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

#
# Colors for error/info messages
#
TXTRED='\e[0;31m'               # Red
TXTGRN='\e[0;32m'               # Green
TXTYLW='\e[0;33m'               # Yellow
BLDRED='\e[1;31m'               # Red-Bold
BLDGRN='\e[1;32m'               # Green-Bold
BLDYLW='\e[1;33m'               # Yellow-Bold
TXTCLR='\e[0m'                  # Text Reset

source jet/credentials.sh

echo "Removing old Zip Files"
ssh ${RACF}@${RHOST} "rm -rf ${ROUT}/gapps/*/*.zip" < /dev/null
echo "Syncing Remote to Flush the Files"
curl ${RSYNC}
echo "GApps are now offline"


find ${COPY_GAPPS_DIR} '(' -iname 'Team-OctOs-AOSP*' -size +100000 ')' -print |
	while read FILENAME
	do
	echo "Moving ${FILENAME##*/}"
	scp ${FILENAME} "${RACF}@${RHOST}:${ROUT}/gapps/aospgapps"
	echo "${FILENAME##*/}"
	done

find ${COPY_GAPPS_DIR} '(' -iname 'Team-OctOs-GPE*' -size +100000 ')' -print |
        while read FILENAME
        do
        echo "Moving ${FILENAME##*/}"
        scp ${FILENAME} "${RACF}@${RHOST}:${ROUT}/gapps/gpegapps"
        echo "${FILENAME##*/}"
        done

echo "Syncing new GApps at remote"
curl ${RSYNC}
