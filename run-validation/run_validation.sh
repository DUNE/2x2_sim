#!/usr/bin/env bash

set -o errexit

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

if [[ "$ARCUBE_RUNTIME" == "NONE" ]]; then
    module load python/3.11
    source validation.venv/bin/activate
fi

edepDir=${ARCUBE_OUTDIR_BASE}/run-convert2h5/output/${ARCUBE_EDEP_NAME}/EDEPSIM_H5
larndDir=${ARCUBE_OUTDIR_BASE}/run-larnd-sim/output/${ARCUBE_LARND_NAME}/LARNDSIM
flowDir=${ARCUBE_OUTDIR_BASE}/run-ndlar-flow/output/${ARCUBE_FLOW_NAME}/FLOW

edepFile=$edepDir/${ARCUBE_EDEP_NAME}.${globalIdx}.EDEPSIM.hdf5
larndFile=$larndDir/${ARCUBE_LARND_NAME}.${globalIdx}.LARNDSIM.hdf5
flowFile=$flowDir/${ARCUBE_FLOW_NAME}.${globalIdx}.FLOW.hdf5

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
