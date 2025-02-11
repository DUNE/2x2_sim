#!/usr/bin/env bash

export ARCUBE_RUNTIME=NONE
export ARCUBE_CONVERT2H5_NAME=Tutorial.convert2h5
export ARCUBE_OUT_NAME=Tutorial.larnd
export ARCUBE_INDEX=0


# By default (i.e. if ARCUBE_RUNTIME isn't set), run on the host's venv
if [[ -z "$ARCUBE_RUNTIME" || "$ARCUBE_RUNTIME" == "NONE" ]]; then
    if [[ "$LMOD_SYSTEM_NAME" == "perlmutter" ]]; then
        module unload python 2>/dev/null
        module unload cudatoolkit 2>/dev/null
        ## CUDA 12.2 makes us crash :(
        # module load cudatoolkit/12.2
        module load cudatoolkit/11.7
        module load python/3.11
    fi
    source ../util/init.inc.sh
    source "$ARCUBE_INSTALL_DIR/larnd.venv/bin/activate"
else
    source ../util/reload_in_container.inc.sh
    source ../util/init.inc.sh
    if [[ -n "$ARCUBE_USE_LOCAL_PRODUCT" && "$ARCUBE_USE_LOCAL_PRODUCT" != "0" ]]; then
        # Allow overriding the container's /opt/venv
        source "$ARCUBE_INSTALL_DIR/larnd.venv/bin/activate"
    fi
fi

inFile=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/edep_sim/MR5_muon_2000_MeV_V4.EDEPSIM.hdf5
#inFile=/global/cfs/cdirs/dune/www/data/2x2/simulation/productions/MiniRun5_1E19_RHC/MiniRun5_1E19_RHC.convert2h5/EDEPSIM_H5/0000000/MiniRun5_1E19_RHC.convert2h5.0000000.EDEPSIM.hdf5
outFile=/global/cfs/cdirs/dune/users/lmlepin/n_Ar_data/larnd-sim/MR5_muon_2000_MeV_V4.LARNDSIM.hdf5

rm -f $outFile

if [[ -n "$ARCUBE_LARNDSIM_CONFIG" ]]; then
    run simulate_pixels.py "$ARCUBE_LARNDSIM_CONFIG" \
        --input_filename "$inFile" \
        --output_filename "$outFile" \
        --rand_seed "$seed"
else
    [ -z "$ARCUBE_LARNDSIM_DETECTOR_PROPERTIES" ] && export ARCUBE_LARNDSIM_DETECTOR_PROPERTIES="larnd-sim/larndsim/detector_properties/2x2.yaml"
    [ -z "$ARCUBE_LARNDSIM_PIXEL_LAYOUT" ] && export ARCUBE_LARNDSIM_PIXEL_LAYOUT="larnd-sim/larndsim/pixel_layouts/multi_tile_layout-2.4.16.yaml"
    [ -z "$ARCUBE_LARNDSIM_RESPONSE_FILE" ] && export ARCUBE_LARNDSIM_RESPONSE_FILE="larnd-sim/larndsim/bin/response_44.npy"
    [ -z "$ARCUBE_LARNDSIM_LUT_FILENAME" ] && export ARCUBE_LARNDSIM_LUT_FILENAME="/global/cfs/cdirs/dune/www/data/2x2/simulation/larndsim_data/light_LUT_M123_v1/lightLUT_M123.npz"
    [ -z "$ARCUBE_LARNDSIM_LIGHT_DET_NOISE_FILENAME" ] && export ARCUBE_LARNDSIM_LIGHT_DET_NOISE_FILENAME="larnd-sim/larndsim/bin/light_noise_2x2_4mod_July2023.npy"
    [ -z "$ARCUBE_LARNDSIM_SIMULATION_PROPERTIES" ] && export ARCUBE_LARNDSIM_SIMULATION_PROPERTIES="larnd-sim/larndsim/simulation_properties/2x2_NuMI_sim.yaml"

    run simulate_pixels.py --config 2x2_mpvmpr --n_events 10 --input_filename "$inFile" \
        --output_filename "$outFile" 
fi