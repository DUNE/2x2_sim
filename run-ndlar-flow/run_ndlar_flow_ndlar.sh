#!/usr/bin/env bash

# By default (i.e. if ARCUBE_RUNTIME isn't set), run on the host
if [[ -z "$ARCUBE_RUNTIME" || "$ARCUBE_RUNTIME" == "NONE" ]]; then
    if [[ "$LMOD_SYSTEM_NAME" == "perlmutter" ]]; then
        module unload python 2>/dev/null
        module load python/3.11
    fi
    source ../util/init.inc.sh
    source "$ARCUBE_INSTALL_DIR/flow.venv/bin/activate"
else
    source ../util/reload_in_container.inc.sh
    source ../util/init.inc.sh
    if [[ -n "$ARCUBE_USE_LOCAL_PRODUCT" && "$ARCUBE_USE_LOCAL_PRODUCT" != "0" ]]; then
        # Allow overriding the container's version
        source "$ARCUBE_INSTALL_DIR/flow.venv/bin/activate"
    fi
fi

inDir=${ARCUBE_OUTDIR_BASE}/run-larnd-sim/$ARCUBE_IN_NAME
inName=$ARCUBE_IN_NAME.$globalIdx
inFile=$(realpath $inDir/LARNDSIM/$subDir/${inName}.LARNDSIM.hdf5)

outFile=$tmpOutDir/${outName}.FLOW.hdf5
rm -f "$outFile"

# charge workflows
workflow1='yamls/ndlar_flow/workflows/charge/charge_event_building.yaml'
workflow2='yamls/ndlar_flow/workflows/charge/charge_event_reconstruction.yaml'
workflow3='yamls/ndlar_flow/workflows/combined/combined_reconstruction.yaml'
workflow4='yamls/ndlar_flow/workflows/charge/prompt_calibration.yaml'
workflow5='yamls/ndlar_flow/workflows/charge/final_calibration.yaml'

cd "$ARCUBE_INSTALL_DIR"/ndlar_flow

# Ensure that the second h5flow doesn't run if the first one crashes. This also
# ensures that we properly report the failure to the production system.
set -o errexit

# AB August 6th 2024: Like 2x2, not currently running the final calibration.
#run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4\
    -i "$inFile" -o "$outFile"

mkdir -p "$outDir/FLOW/$subDir"
mv "$outFile" "$outDir/FLOW/$subDir"
