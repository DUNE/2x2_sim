#!/bin/bash

# module load singularity
if [[ -z "$ARCUBE_CONTAINER_DIR" ]]; then
    echo "Set \$ARCUBE_CONTAINER_DIR to a directory to store singularity container file."
    exit 1
fi

if [[ -d "$ARCUBE_CONTAINER_DIR" ]]
then
    echo "Found $ARCUBE_CONTAINER_DIR"
else
    echo "Making $ARCUBE_CONTAINER_DIR"
    mkdir $ARCUBE_CONTAINER_DIR
fi

export SINGULARITY_CACHEDIR=$ARCUBE_CONTAINER_DIR/.singularity
export SINGULARITY_TMPDIR=$ARCUBE_CONTAINER_DIR/.singularity/tmp

# edit to pull a different container
CONTAINER_NAME='sim2x2:genie_edep.LFG_testing.20230228.v2'

mkdir -p $SINGULARITY_TMPDIR

echo "Pulling container... this will take O(1 hour)..."
echo "Container name: ${CONTAINER_NAME}"

singularity pull docker://mjkramer/${CONTAINER_NAME}

mv ${CONTAINER_NAME//:/_}.sif $ARCUBE_CONTAINER_DIR
echo "Finished."
