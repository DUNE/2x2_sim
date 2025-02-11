#!/usr/bin/env bash

export ARCUBE_RUNTIME=NONE
export ARCUBE_IN_NAME=Tutorial.larnd
export ARCUBE_OUT_NAME=Tutorial.flow
export ARCUBE_INDEX=0

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


inFile=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/larnd-sim/MR5_muon_2000_MeV_V4.LARNDSIM.hdf5
#inFile=/pscratch/sd/l/lmlepin/2x2_sim/run-larnd-sim/MR5_LM_NU_TEST.LARNDSIM.hdf5
#inFile=/global/cfs/cdirs/dune/www/data/2x2/simulation/productions/MiniRun5_1E19_RHC/MiniRun5_1E19_RHC.larnd.beta2a/LARNDSIM/0000000/MiniRun5_1E19_RHC.larnd.0000000.LARNDSIM.hdf5

outFile=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/flow/MR5_muon_2000_MeV_V4.FLOW.hdf5
#outFile=MR5_LM_NU_TEST.FLOW.hdf5
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

# charge-light trigger matching
workflow8='yamls/proto_nd_flow/workflows/charge/charge_light_assoc.yaml'

cd "ndlar_flow"

# Ensure that the second h5flow doesn't run if the first one crashes. This also
# ensures that we properly report the failure to the production system.
set -o errexit

#run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
#    -i "$inFile" -o "$outFile"

run h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
    -i "$inFile" -o "$outFile"

run h5flow -c $workflow6 $workflow7\
    -i "$inFile" -o "$outFile"

run h5flow -c $workflow8\
    -i "$outFile" -o "$outFile"
