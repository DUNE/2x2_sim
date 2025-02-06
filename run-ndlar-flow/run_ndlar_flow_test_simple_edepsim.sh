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

inDir=${ARCUBE_OUTDIR_BASE}/run-larnd-sim/
inName=$1
inFile=$(realpath $inDir/TEST_LARNDSIM/$subDir/${inName}.LARNDSIM.hdf5)

outName=$1
outFile=$tmpOutDir/${outName}.CHARGE_FLOW.hdf5
rm -f "$outFile"

# charge workflows
workflow1='yamls/proto_nd_flow/workflows/charge/charge_event_building_mc.yaml'
workflow2='yamls/proto_nd_flow/workflows/charge/charge_event_reconstruction_mc.yaml'
workflow3='yamls/proto_nd_flow/workflows/combined/combined_reconstruction_mc.yaml'
workflow4='yamls/proto_nd_flow/workflows/charge/prompt_calibration_mc.yaml'
workflow5='yamls/proto_nd_flow/workflows/charge/final_calibration_mc.yaml'

# light workflows
#workflow6='yamls/proto_nd_flow/workflows/light/light_event_building_mc.yaml'
#workflow7='yamls/proto_nd_flow/workflows/light/light_event_reconstruction_mc.yaml'

# charge-light trigger matching
#workflow8='yamls/proto_nd_flow/workflows/charge/charge_light_assoc_mc.yaml'

cd "$ARCUBE_INSTALL_DIR"/ndlar_flow

# Ensure that the second h5flow doesn't run if the first one crashes. This also
# ensures that we properly report the failure to the production system.
set -o errexit

#run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
#    -i "$inFile" -o "$outFile"

#run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
#    -i "$inFile" -o "$outFile"

#MiniRun 6.1 without the hit merger worksflow
run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4\
    -i "$inFile" -o "$outFile"

#run h5flow -c $workflow6 $workflow7\
#    -i "$inFile" -o "$outFile"
#
#run h5flow -c $workflow8\
#    -i "$outFile" -o "$outFile"

mkdir -p "$outDir/TEST_CHARGE_FLOW/$subDir"
mv "$outFile" "$outDir/TEST_CHARGE_FLOW/$subDir"
