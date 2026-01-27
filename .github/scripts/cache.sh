#!/bin/sh -l

set -eu

### VARIABLES ###

# From action env:
#   REPO_DIR

ACT_SCRIPT_PATH=_visualize/scripts

### SETUP ###

# Store absolute path
cd $REPO_DIR
REPO_ROOT=$(pwd)

### RUN CACHE SCRIPT ###

cd $REPO_ROOT/$ACT_SCRIPT_PATH
./CACHE.sh

exit 0
