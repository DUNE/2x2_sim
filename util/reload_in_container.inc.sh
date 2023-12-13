#!/usr/bin/env bash

# assume Shifter if ARCUBE_RUNTIME is unset
export ARCUBE_RUNTIME=${ARCUBE_RUNTIME:-SHIFTER}

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

elif [[ "$ARCUBE_RUNTIME" == "PODMAN-HPC" ]]; then
    # The 2x2_sim directory:
    arcube_dir=$(realpath $(dirname "$BASH_SOURCE")/..)
    # HACK: Check if we're "in podman" by seeing whether our UID is 0 (root)
    # This will break if you run 2x2_sim as the true superuser, but why would
    # you do that?
    if [[ "$(id -u)" != "0" ]]; then
        podman-hpc run --rm --env-file <(env | grep ARCUBE) --gpu -w "$(realpath $(dirname "$0"))" \
            -v "$arcube_dir:$arcube_dir" -v "$SCRATCH:$SCRATCH" -v /dvs_ro/cfs:/dvs_ro/cfs \
            -v /opt/nvidia/hpc_sdk/Linux_x86_64/23.9:/opt/cuda \
            "$ARCUBE_CONTAINER" "$(realpath "$0")" "$@"
        exit
    fi

else
    echo "Unsupported \$ARCUBE_RUNTIME"
    exit
fi

# The below runs in the "reloaded" process

if [[ "$ARCUBE_RUNTIME" == "SHIFTER" ]]; then
    if [[ -e /environment ]]; then
        source /environment # apptainer-built containters
    fi
elif [[ "$ARCUBE_RUNTIME" == "SINGULARITY" ]]; then
    # "singularity pull" overwrites /environment
    source "$ARCUBE_DIR"/admin/container_env."$ARCUBE_CONTAINER".sh
elif [[ "$ARCUBE_RUNTIME" == "PODMAN-HPC" ]]; then
    # Ideally, we'd just tell podman-hpc to overlay the host's libcudart and
    # libcudablas into the container's /usr/lib64, but that currently produces a
    # useless error. So for now we just bind mount /opt/cuda (above) and set
    # LD_LIBRARY_PATH here.
    export LD_LIBRARY_PATH=/opt/cuda/math_libs/12.2/targets/x86_64-linux/lib:/opt/cuda/cuda/12.2/lib64:$LD_LIBRARY_PATH
fi
