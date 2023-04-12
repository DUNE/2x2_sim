#!/usr/bin/env bash

# Reload in Shifter if necessary
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
    exit
fi

echo "If this fails, inspect and modify run-spill-build/libTG4Event/MAKEP"
echo "or regenerate MAKEP from an arbitrary edep-sim file (see makeLibTG4Event.sh)"

source /environment

cd libTG4Event
bash MAKEP
