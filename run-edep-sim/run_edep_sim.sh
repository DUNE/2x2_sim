#!/usr/bin/env bash

# Reload in Shifter if necessary
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
    exit
fi

source environment_local.sh

## HACK: This will not wait for other tasks on the node to complete
# if [[ "$SLURM_LOCALID" == 0 ]]; then
#     monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
#     ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
# fi

# Start seeds at 1 instead of 0, just in case GENIE does something
# weird when given zero (e.g. use the current time)
# NOTE: We just use the fixed Edep default seed of
seed=$((1 + ARCUBE_INDEX))
echo "Seed is $seed"

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outDir=$PWD/output/$ARCUBE_OUT_NAME
outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/tmp_bin/time      # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

edepRootFile=$outDir/EDEPSIM/${outName}.EDEPSIM.root
mkdir -p "$(dirname "$edepRootFile")"
rm -f "$edepRootFile"

edepCode="/edep/runId $ARCUBE_INDEX"

export ARCUBE_GEOM_EDEP=${ARCUBE_GEOM_EDEP:-$ARCUBE_GEOM}

run edep-sim -C -g "$ARCUBE_GEOM_EDEP" -o "$edepRootFile" -e "$ARCUBE_NEVENTS" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"
