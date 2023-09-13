#!/usr/bin/env bash

# assume Shifter if ARCUBE_RUNTIME is unset
export ARCUBE_RUNTIME=${ARCUBE_RUNTIME:-SHIFTER}

if [[ -z "$ARCUBE_CONTAINER" ]]; then
    echo "Set \$ARCUBE_CONTAINER to the GENIE+edep-sim container"
    exit 1
fi

if [[ "$ARCUBE_RUNTIME" == "SHIFTER" ]]; then
    # Reload in Shifter
    if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
        shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
        exit
    fi

elif [[ "$ARCUBE_RUNTIME" == "SINGULARITY" ]]; then
    # Or reload in Singularity
    if [[ "$SINGULARITY_NAME" != "$ARCUBE_CONTAINER" ]]; then
        singularity exec -B $ARCUBE_DIR $ARCUBE_CONTAINER_DIR/$ARCUBE_CONTAINER /bin/bash "$0" "$@"
        exit
    fi

else
    echo "Unsupported \$ARCUBE_RUNTIME"
    exit
fi

if [[ "$ARCUBE_RUNTIME" == "SHIFTER" ]]; then
    source /environment         # provided by the container
elif [[ "$ARCUBE_RUNTIME" == "SINGULARITY" ]]; then
    # "singularity pull" overwrites /environment
    source "$ARCUBE_DIR"/admin/container_env."$ARCUBE_CONTAINER".sh
else
    echo "Unsupported \$ARCUBE_RUNTIME"
    exit
fi

rm -rf convert.venv
python3 -m venv convert.venv
source convert.venv/bin/activate

pip3 install -r requirements.txt
