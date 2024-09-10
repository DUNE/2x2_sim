#!/usr/bin/env bash

set -o errexit

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

if [[ "$ARCUBE_RUNTIME" == "NONE" ]]; then
    module load python/3.11
    source validation.venv/bin/activate
fi

edepDir=${ARCUBE_OUTDIR_BASE}/run-convert2h5/${ARCUBE_EDEP_NAME}/EDEPSIM_H5/$subDir
larndDir=${ARCUBE_OUTDIR_BASE}/run-larnd-sim/${ARCUBE_LARND_NAME}/LARNDSIM/$subDir
flowDir=${ARCUBE_OUTDIR_BASE}/run-ndlar-flow/${ARCUBE_FLOW_NAME}/FLOW/$subDir

edepFile=$edepDir/${ARCUBE_EDEP_NAME}.${globalIdx}.EDEPSIM.hdf5
larndFile=$larndDir/${ARCUBE_LARND_NAME}.${globalIdx}.LARNDSIM.hdf5
flowFile=$flowDir/${ARCUBE_FLOW_NAME}.${globalIdx}.FLOW.hdf5

codeDir=$PWD

plotOutDir=$outDir/PLOTS
mkdir -p "$plotOutDir"
cd "$plotOutDir"

run_in() {
    direc=$1/$subDir; shift
    mkdir -p "$direc"
    pushd "$direc"
    run "$@"
    popd
}

# If ARCUBE_PLOT_TYPE isn't set, run everything.

if [[ -z "$ARCUBE_PLOT_TYPE" || "$ARCUBE_PLOT_TYPE" == "EDEPSIM_DUMPTREE" ]]; then
    if [[ -n "$ARCUBE_EDEP_NAME" ]]; then
        run_in EDEPSIM_DUMPTREE "$codeDir"/edepsim_validation.py --sim_file "$edepFile" --input_type edep
    fi
fi
if [[ -z "$ARCUBE_PLOT_TYPE" || "$ARCUBE_PLOT_TYPE" == "LARNDSIM_EDEPTRUTH" ]]; then
    if [[ -n "$ARCUBE_LARND_NAME" ]]; then
        run_in LARNDSIM_EDEPTRUTH "$codeDir"/edepsim_validation.py --sim_file "$larndFile" --input_type larnd
    fi
fi
if [[ -z "$ARCUBE_PLOT_TYPE" || "$ARCUBE_PLOT_TYPE" == "LARNDSIM" ]]; then
    if [[ -n "$ARCUBE_LARND_NAME" ]]; then
        run_in LARNDSIM "$codeDir"/larndsim_validation.py --sim_file "$larndFile"
    fi
fi
if [[ -z "$ARCUBE_PLOT_TYPE" || "$ARCUBE_PLOT_TYPE" == "FLOW" ]]; then
    if [[ -n "$ARCUBE_FLOW_NAME" ]]; then
        run_in FLOW "$codeDir"/flow_validation.py --flow_file "$flowFile"
    fi
fi
if [[ -z "$ARCUBE_PLOT_TYPE" || "$ARCUBE_PLOT_TYPE" == "FLOW_CPM" ]]; then
    if [[ -n "$ARCUBE_FLOW_NAME" ]]; then
        run_in FLOW_CPM "$codeDir"/CPM_validation.py --flow_file "$flowFile"
    fi
fi
