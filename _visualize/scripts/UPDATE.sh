#!/bin/bash
# Run this script to refresh data.
# Script selection can be customized through a text file UPDATE_<TAG>.txt
# Providing the argument <TAG> to this script will select UPDATE_<TAG>.txt
# The input list from UPDATE_FULL.txt is selected by default.

if [ -z "$1" ]; then
    TAG=FULL
else
    TAG="$1"
fi

exec &> ../LAST_${TAG}_UPDATE.log

export GITHUB_DATA=../../visualize/github-data
DATELOG=../LAST_${TAG}_UPDATE.txt

# On exit
function finish {
    # Log end time
    echo -e "END\t$(date -u)" >> $DATELOG
}
trap finish EXIT

# Stop and Log for failed scripts
function errorCheck() {
    if [ $ret -ne 0 ]; then
        echo "FAILED - $1"
        echo -e "FAILED\t$1" >> $DATELOG
        exit 1
    fi
}

# Basic script run procedure
function runScript() {
    echo "Run - $1"
    python -u $1
    ret=$?
    errorCheck "$1"
}


# Check Python requirements
runScript python_check.py

echo "RUNNING ${TAG} UPDATE SCRIPT"

# Log start time
echo -e "$(date -u '+%F-%H')" > $DATELOG
echo -e "START\t$(date -u)" >> $DATELOG

# RUN THIS FIRST
runScript cleanup_inputs.py

# DATA COLLECTION
readarray -t script_array < <(grep -v '^#' UPDATE_${TAG}.txt)
echo "Data scripts queued: (${script_array[*]})"
for datascript in "${script_array[@]}"; do
    runScript ${datascript}.py
done

echo "${TAG} UPDATE COMPLETE"
