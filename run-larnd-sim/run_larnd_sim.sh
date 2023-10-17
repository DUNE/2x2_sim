#!/usr/bin/env bash

module load cudatoolkit/11.7
module load python/3.9-anaconda-2021.11

source larnd.venv/bin/activate

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

seed=$((1 + ARCUBE_INDEX))

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

inDir=$PWD/../run-convert2h5/output/$ARCUBE_CONVERT2H5_NAME

outDir=$PWD/output/$ARCUBE_OUT_NAME
mkdir -p $outDir

outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
inName=$ARCUBE_CONVERT2H5_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=/usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

inFile=$inDir/EDEPSIM_H5/${inName}.EDEPSIM.hdf5

larndOutDir=$outDir/LARNDSIM
mkdir -p $larndOutDir

outFile=$larndOutDir/${outName}.LARNDSIM.hdf5
rm -f "$outFile"

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
