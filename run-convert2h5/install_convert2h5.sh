#!/usr/bin/env bash

if [[ -z "$ARCUBE_CONTAINER" ]]; then
    echo "Set \$ARCUBE_CONTAINER to the GENIE+edep-sim container"
    exit 1
fi

# Reload in Shifter
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
    exit
fi

source /environment             # from the container

rm -rf convert.venv
python3 -m venv convert.venv
source convert.venv/bin/activate

pip3 install -r requirements.txt
