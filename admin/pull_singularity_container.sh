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

mkdir $SINGULARITY_TMPDIR

echo "Pulling container... this will take O(1 hour)..."
singularity pull docker://mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2

mv sim2x2_genie_edep.LFG_testing.20230228.v2.sif $ARCUBE_CONTAINER_DIR
echo "Finished."
