#!/bin/bash

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LOCKFILE="tmp/cron_media_sorter.lock"
SCRIPTFILE=$DIR/MediaSorter.rb

# Safe guard. Don't start if the lock is set
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
	echo "Already running"
	exit
fi

# Make sure the lockfile is removed when we exit and the claim it
trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

# Run the updating script
ruby ${SCRIPTFILE}

# Remove the lock
rm -f ${LOCKFILE}