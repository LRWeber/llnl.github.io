#!/bin/bash
# Run this script to refresh all data

TAG=FULL  # Sets a default value
export GITHUB_DATA=../../visualize/github-data

SCRIPT_LIST=(  # in order of execution
# --- BASIC DATA ---
'get_repos_info'  # Required before any other repo scripts (output used as repo list)
'get_internal_members'  # Required before any other member scripts (output used as member list)
# --- EXTERNAL V INTERNAL ---
'get_members_extrepos'
'get_repos_users'
# --- ADDITIONAL REPO DETAILS ---
'get_repos_languages'
'get_repos_topics'
'get_repos_activitycommits'
'get_repos_dependencies'
'get_dependency_info'
# --- HISTORY FOR ALL TIME ---
'get_repos_starhistory'
'get_repos_releases'
'get_repos_creationhistory'
# --- ADDITIONAL DATA PROCESSING ---
'gather_repo_metadata'  # Generate simplified metadata file
)
INCLUDE_LIST=()
EXCLUDE_LIST=()


USAGE="$(basename $0) [-h] [-t <tag>] [-i \"<space separated string>\"] [-e \"<space separated string>\"]"

function help {
cat <<-END

Usage: $USAGE

Run GitHub data update scripts. Requires environment variable GITHUB_API_TOKEN.

    -h
      Display this help and exit.
    
    -t <tag>
      Set a custom label for this run's logging files.
      (e.g. LAST_<TAG>_UPDATE.txt, LAST_<TAG>_UPDATE.log)
      Default label is "FULL"
    
    -i "<space separated string>"
      List of script names. This will run ONLY these scripts.

    -e "<space separated string>"
      List of script names. This will EXCLUDE these scripts.

END
}

while getopts ":ht:i:e:" opt; do
    case $opt in
        h)
            help
            exit 0
            ;;
        t)
            tARG=$OPTARG
            TAG=$(echo ${tARG//[^a-zA-Z0-9]/} | tr '[:lower:]' '[:upper:]')
            ;;
        i)
            iARG=$OPTARG
            INCLUDE_LIST=($iARG)
            ;;
        e)
            eARG=$OPTARG
            EXCLUDE_LIST=($eARG)
            ;;
        \?)
            echo -e ${CError}"Invalid option: -$OPTARG"${NC} >&2
            echo "Usage: $USAGE" >&2
            exit 1
            ;;
        :)
            echo -e ${CError}"Invalid option: -$OPTARG requires an argument"${NC} >&2
            echo "Usage: $USAGE" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -gt 0 ]; then
    echo -e ${CError}"ERROR: Invalid number of arguments"${NC} >&2
    echo "Usage: $USAGE" >&2
    exit 1
fi


DATELOG=../LAST_${TAG}_UPDATE.txt

exec &> ../LAST_${TAG}_UPDATE.log

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


# # Finalize data script list
# echo "INCLUDE: (${INCLUDE_LIST[*]})"
# echo "EXCLUDE: (${EXCLUDE_LIST[*]})"
# # TODO process via python script

# Check Python requirements
runScript python_check.py

echo "RUNNING ${TAG} UPDATE SCRIPT"

# Log start time
echo -e "$(date -u '+%F-%H')" > $DATELOG
echo -e "START\t$(date -u)" >> $DATELOG

# RUN THIS FIRST
runScript cleanup_inputs.py

echo "Data scripts queued: (${SCRIPT_LIST[*]})"
# DATA COLLECTION
for datascript in "${SCRIPT_LIST[@]}"; do
    runScript ${datascript}.py
done

# RUN THIS LAST
runScript build_yearlist.py  # Used in case of long term cumulative data


echo "${TAG} UPDATE COMPLETE"
