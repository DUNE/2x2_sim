#!/usr/bin/env bash

module load python

source flow.venv/bin/activate

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

# TODO actually use this seed
seed=$((1 + ARCUBE_INDEX))

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

inDir=$PWD/../run-larnd-sim/output/$ARCUBE_IN_NAME

outDir=$PWD/output/$ARCUBE_OUT_NAME
mkdir -p $outDir

outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
inName=$ARCUBE_IN_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=/usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

inFile=$inDir/LARNDSIM/${inName}.LARNDSIM.hdf5

flowOutDir=$outDir/FLOW
mkdir -p $flowOutDir

outFile=$flowOutDir/${outName}.FLOW.hdf5
rm -f "$outFile"

# charge workflows
workflow1='yamls/proto_nd_flow/workflows/charge/charge_event_building.yaml'
workflow2='yamls/proto_nd_flow/workflows/charge/charge_event_reconstruction.yaml'
workflow3='yamls/proto_nd_flow/workflows/combined/combined_reconstruction.yaml'
workflow4='yamls/proto_nd_flow/workflows/charge/prompt_calibration.yaml'
workflow5='yamls/proto_nd_flow/workflows/charge/final_calibration.yaml'

# light workflows
workflow6='yamls/proto_nd_flow/workflows/light/light_event_building_mc.yaml'
workflow7='yamls/proto_nd_flow/workflows/light/light_event_reconstruction.yaml'

cd ndlar_flow

# Ensure that the second h5flow doesn't run if the first one crashes. This also
# ensures that we properly report the failure to the production system.
set -o errexit

run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
    -i $inFile -o $outFile

run h5flow -c $workflow6 $workflow7\
    -i $inFile -o $outFile
