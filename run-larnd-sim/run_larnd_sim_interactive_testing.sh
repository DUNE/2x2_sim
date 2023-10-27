#!/usr/bin/env bash

module load cudatoolkit         # 11.7
module load python              # 3.9-anaconda-2021.11

source larnd.venv/bin/activate


export ARCUBE_INDEX=0
export ARCUBE_CONVERT2H5_NAME="MiniProdN1p1_NDLAr_1E19_RHC.convert2h5"
export ARCUBE_OUT_NAME="MiniProdN1p1_NDLAr_1E19_RHC.larnd"


seed=$((1 + ARCUBE_INDEX))

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

inDir=/pscratch/sd/a/abooth/MiniProdN1p1-v1r1/run-convert2h5/output/$ARCUBE_CONVERT2H5_NAME

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

inFile=$inDir/EDEPSIM_H5/${inName}.EDEPSIM.h5

larndOutDir=$outDir/LARNDSIM
mkdir -p $larndOutDir

outFile=$larndOutDir/${outName}.LARNDSIM.h5
rm -f "$outFile"


ARCUBE_LARNDSIM_DETECTOR_PROPERTIES="larnd-sim/larndsim/detector_properties/ndlar-module.yaml"
ARCUBE_LARNDSIM_PIXEL_LAYOUT="larnd-sim/larndsim/pixel_layouts/multi_tile_layout-3.0.40.yaml"
ARCUBE_LARNDSIM_RESPONSE_FILE="larnd-sim/larndsim/bin/response_38.npy"
ARCUBE_LARNDSIM_SIMULATION_PROPERTIES="larnd-sim/larndsim/simulation_properties/NDLAr_LBNF_sim.yaml"

run simulate_pixels.py --input_filename "$inFile" \
    --output_filename "$outFile" \
    --detector_properties "$ARCUBE_LARNDSIM_DETECTOR_PROPERTIES" \
    --pixel_layout "$ARCUBE_LARNDSIM_PIXEL_LAYOUT" \
    --response_file "$ARCUBE_LARNDSIM_RESPONSE_FILE" \
    --rand_seed $seed \
    --simulation_properties "$ARCUBE_LARNDSIM_SIMULATION_PROPERTIES" \
    --save_memory "./memory_info"

