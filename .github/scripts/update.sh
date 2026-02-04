#!/bin/sh -l

set -eu

### VARIABLES ###

# From action env:
#   REPO_DIR
#   TAG

ACT_LOG_PATH=_visualize/LAST_${TAG}_UPDATE.txt
ACT_INPUT_PATH=_visualize
ACT_DATA_PATH=visualize/github-data
ACT_SCRIPT_PATH=_visualize/scripts

### SETUP ###

# Store absolute path
cd $REPO_DIR
REPO_ROOT=$(pwd)

# Store previous END timestamp
OLD_END=$(cat $ACT_LOG_PATH | grep END | cut -f 2)
OLD_END=$(date --date="$OLD_END" "+%s")

### RUN UPDATE SCRIPT ###

cd $REPO_ROOT/$ACT_SCRIPT_PATH
./UPDATE.sh $TAG

### VALIDATE UPDATE ###

cd $REPO_ROOT

#   Timestamp log changed
cat $ACT_LOG_PATH
if [ $(git diff --name-only HEAD | grep -c "${ACT_LOG_PATH}") -ne "1" ]
    then
        echo "UPDATE FAILED - Timestamp log unchanged"
        exit 1
    else
        echo "Timestamp log confirmed"
fi

#   Logged START and END without FAILED
if [ $(cat $ACT_LOG_PATH | grep -c FAILED) -ne "0" ] || [ $(cat $ACT_LOG_PATH | grep -c START) -ne "1" ] || [ $(cat $ACT_LOG_PATH | grep -c END) -ne "1" ]
    then
        echo "UPDATE FAILED - Invalid timestamp log"
        exit 1
    else
        echo "Timestamp log valid"
fi

#   New START is later than previous END
NEW_START=$(cat $ACT_LOG_PATH | grep START | cut -f 2)
NEW_START=$(date --date="$NEW_START" "+%s")
if [ "$OLD_END" -gt "$NEW_START" ]
    then
        echo "UPDATE FAILED - New START is earlier than previous END"
        exit 1
    else
        echo "START timestamp valid"
fi

#   All changes are to valid files only
git diff --name-only HEAD
CHANGE_COUNT=$(git diff --name-only HEAD | grep -c -E ".+")
VALID_COUNT=$(git diff --name-only HEAD | grep -c -E "(^${ACT_DATA_PATH}\/\S+\.json$)|(^${ACT_INPUT_PATH}\/input\S+\.json$)|(${ACT_LOG_PATH})")
if [ "$CHANGE_COUNT" -ne "$VALID_COUNT" ]
    then
        echo "UPDATE FAILED - Unexpected file changes"
        exit 1
    else
        echo "Changed files validated"
fi

exit 0
