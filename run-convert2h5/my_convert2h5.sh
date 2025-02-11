#!/usr/bin/env bash

export ARCUBE_RUNTIME=SHIFTER
export ARCUBE_CONTAINER=mjkramer/sim2x2:ndlar011
export ARCUBE_ACTIVE_VOLUME=volTPCActive
export ARCUBE_SPILL_NAME=Tutorial.spill
export ARCUBE_OUT_NAME=Tutorial.convert2h5
export ARCUBE_INDEX=0

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh


# If we're using a container, it's responsible for the Python libraries. With no
# container, use a venv.
if [[ "$ARCUBE_RUNTIME" == "NONE" ]]; then
    source convert.venv/bin/activate
fi


#inFile=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/edep_sim/2x2_neutron_captures_filtered_edepsim.root
inFile=/pscratch/sd/l/lmlepin/edep-sim_test/MR5_muon_2000_MeV_edepsim_V4.root
outDir=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/edep_sim
outFile=${outDir}/MR5_muon_2000_MeV_V4.EDEPSIM.hdf5

if [[ "$ARCUBE_KEEP_ALL_DETS" == "1" ]]; then
    keepAllDets=--keep_all_dets
else
    keepAllDets=""
fi

# After going from ROOT 6.14.06 to 6.28.06, apparently we need to point CPATH to
# the edepsim-io headers. Otherwise convert2h5 fails. (This "should" be set in
# the container already.)
export CPATH=$EDEPSIM/include/EDepSim:$CPATH

run ./convert_edepsim_roottoh5.py --input_file "$inFile" --output_file "$outFile" "$keepAllDets" --gps True
