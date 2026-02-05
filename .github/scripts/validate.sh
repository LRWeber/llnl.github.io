#!/bin/sh -l

set -u

### VARIABLES ###

# From action env:
#   REPO_DIR
#   TAG

ACT_DATA_PATH=visualize/github-data
ACT_INPUT_PATH=_visualize
ACT_LOG_PATH=_visualize
ACT_LOG_FILE=${ACT_LOG_PATH}/LAST_${TAG}_UPDATE.txt

### VALIDATE UPDATE ###

cd $REPO_DIR

#   Timestamp log changed
cat $ACT_LOG_FILE
if [ $(git diff --name-only HEAD | grep -c "${ACT_LOG_FILE}") -ne "1" ]
    then
        # or is new
        if [ $(git status --porcelain | grep "^?? " | awk '{print $2}' | grep -c "${ACT_LOG_FILE}") -ne "1" ]
            then
                echo "UPDATE FAILED - Timestamp log unchanged"
                exit 1
            else
                echo "Timestamp log confirmed as new"
        fi
    else
        echo "Timestamp log confirmed as updated"
fi

#   Logged START and END without FAILED
if [ $(cat $ACT_LOG_FILE | grep -c FAILED) -ne "0" ] || [ $(cat $ACT_LOG_FILE | grep -c START) -ne "1" ] || [ $(cat $ACT_LOG_FILE | grep -c END) -ne "1" ]
    then
        echo "UPDATE FAILED - Invalid timestamp log"
        exit 1
    else
        echo "Timestamp log valid"
fi

#   All new files are valid additions ( <ACT_DATA_PATH>/*.json | <ACT_LOG_PATH>/LAST_*_UPDATE.txt )
git status --porcelain | grep --color=never "^?? "
UNTRACKED_COUNT=$(git status --porcelain | grep -c "^?? ")
VALID_UNTRACKED_COUNT=$(git status --porcelain | grep "^?? " | awk '{print $2}' | grep -c -E "(^${ACT_DATA_PATH}\/\S+\.json$)|(^${ACT_LOG_PATH}\/LAST_\S+\_UPDATE.txt$)")
if [ "$UNTRACKED_COUNT" -ne "$VALID_UNTRACKED_COUNT" ]
    then
        echo "UPDATE FAILED - Unexpected new files"
        exit 1
    else
        echo "New files validated"
fi

#   All changes are to expected files only ( <ACT_DATA_PATH>/*.json | <ACT_INPUT_PATH>/input*.json | <ACT_LOG_PATH>/LAST_*_UPDATE.txt )
git diff --name-only HEAD
CHANGE_COUNT=$(git diff --name-only HEAD | grep -c -E ".+")
VALID_CHANGE_COUNT=$(git diff --name-only HEAD | grep -c -E "(^${ACT_DATA_PATH}\/\S+\.json$)|(^${ACT_INPUT_PATH}\/input\S+\.json$)|(^${ACT_LOG_PATH}\/LAST_\S+\_UPDATE.txt$)")
if [ "$CHANGE_COUNT" -ne "$VALID_CHANGE_COUNT" ]
    then
        echo "UPDATE FAILED - Unexpected file changes"
        exit 1
    else
        echo "Changed files validated"
fi

echo "VALIDATION SUCCESSFUL - All checks passed"

exit 0
