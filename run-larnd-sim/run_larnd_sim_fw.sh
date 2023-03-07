#!/usr/bin/env bash

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

# source venv/bin/activate
source load_larnd_sim.sh

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuCount=${#dk2nuAll[@]}
dk2nuIdx=$((globalIdx % dk2nuCount))
dk2nuFile=${dk2nuAll[$dk2nuIdx]}
echo "dk2nuIdx is $dk2nuIdx"
echo "dk2nuFile is $dk2nuFile"

outDir=$PWD/output/$ARCUBE_OUT_NAME
mkdir -p $outDir

outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%03d" $((globalIdx / dk2nuCount)))
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=/usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

inFile=$outDir/EDEPSIM_H5/${outName}.EDEPSIM.h5

larndOutDir=$outDir/LARNDSIM
mkdir -p $larndOutDir

outFile=$larndOutDir/${outName}.LARNDSIM.h5
rm -f $outFile

run simulate_pixels_spills.py --input_filename "$inFile" \
    --output_filename "$outFile" \
    --detector_properties larnd-sim/larndsim/detector_properties/2x2.yaml \
    --pixel_layout larnd-sim/larndsim/pixel_layouts/multi_tile_layout-2.3.16.yaml \
    --response_file larnd-sim/larndsim/bin/response_44.npy \
    --light_lut_filename larnd-sim/larndsim/bin/lightLUT.npz \
    --light_det_noise_filename larnd-sim/larndsim/bin/light_noise-2x2-example.npy
