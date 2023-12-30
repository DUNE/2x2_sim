#!/usr/bin/env bash

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

inDir=${ARCUBE_OUTDIR_BASE}/run-convert2h5/$ARCUBE_CONVERT2H5_NAME
inName=$ARCUBE_CONVERT2H5_NAME.$globalIdx
inFile=$(realpath $inDir/EDEPSIM_H5/${inName}.EDEPSIM.hdf5)

outFile=$tmpOutDir/${outName}.LARNDSIM.hdf5
rm -f "$outFile"

cd "$ARCUBE_INSTALL_DIR"

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

    run simulate_pixels.py --input_filename "$inFile" \
        --output_filename "$outFile" \
        --detector_properties "$ARCUBE_LARNDSIM_DETECTOR_PROPERTIES" \
        --pixel_layout "$ARCUBE_LARNDSIM_PIXEL_LAYOUT" \
        --response_file "$ARCUBE_LARNDSIM_RESPONSE_FILE" \
        --light_lut_filename  "$ARCUBE_LARNDSIM_LUT_FILENAME" \
        --light_det_noise_filename "$ARCUBE_LARNDSIM_LIGHT_DET_NOISE_FILENAME" \
        --rand_seed $seed \
        --simulation_properties "$ARCUBE_LARNDSIM_SIMULATION_PROPERTIES"
fi

mkdir -p "$outDir"/LARNDSIM
mv "$outFile" "$outDir"/LARNDSIM
