#!/usr/bin/env bash

set -o errexit

module load python

source validation.venv/bin/activate

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outDir=$PWD/output/$ARCUBE_OUT_NAME
mkdir -p "$outDir"

outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")

edepDir=$PWD/../run-convert2h5/output/${ARCUBE_EDEP_NAME}/EDEPSIM_H5
larndDir=$PWD/../run-larnd-sim/output/${ARCUBE_LARND_NAME}/LARNDSIM
flowDir=$PWD/../run-ndlar-flow/output/${ARCUBE_FLOW_NAME}/FLOW

edepFile=$edepDir/${ARCUBE_EDEP_NAME}.$(printf "%05d" "$globalIdx").EDEPSIM.h5
larndFile=$larndDir/${ARCUBE_LARND_NAME}.$(printf "%05d" "$globalIdx").LARNDSIM.h5
flowFile=$flowDir/${ARCUBE_FLOW_NAME}.$(printf "%05d" "$globalIdx").FLOW.h5

timeFile=$outDir/TIMING/${outName}.time
mkdir -p "$(dirname "$timeFile")"
timeProg=/usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

codeDir=$PWD

plotOutDir=$outDir/PLOTS
mkdir -p "$plotOutDir"
cd "$plotOutDir"

run_in() {
    direc=$1; shift
    mkdir -p "$direc"
    pushd "$direc"
    run "$@"
    popd
}

run_in EDEPSIM_DUMPTREE "$codeDir"/edepsim_validation.py --sim_file "$edepFile" --input_type edep
run_in LARNDSIM_EDEPTRUTH "$codeDir"/edepsim_validation.py --sim_file "$larndFile" --input_type larnd
run_in LARNDSIM "$codeDir"/larndsim_validation.py --sim_file "$larndFile"
run_in FLOW "$codeDir"/flow_validation.py --flow_file "$flowFile"
run_in FLOW_CPM "$codeDir"/CPM_validation.py --flow_file "$flowFile"
