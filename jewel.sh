#!/bin/bash
## Build Automation Scripts
##
## Copywrite 2014 - Donald Hoskins <grommish@gmail.com>
## on behalf of Team Octos et al.

## Check to see if there are build args
## First Argument is for the -j concurrent build threads - Defaults to -j21 unless
## you set it otherwise.  Careful, or it will melt your machine!
BSPEED=$2
PUSH=$1
: ${BSPEED:="10"}
: ${PUSH:=false}
BVARIANT=`basename $0 | cut -f 1 -d "."`
jet/bscript.sh ${PUSH} ${BSPEED} ${BVARIANT}
