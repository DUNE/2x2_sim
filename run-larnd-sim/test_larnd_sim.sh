#!/usr/bin/env bash

# source load_larnd_sim.sh

outName=NuMI_RHC_CHERRY
outDir=../run-edep-sim/output/"$outName"
mkdir -p "$outDir"/LARNDSIM

edepH5="$outDir"/EDEPSIM_H5/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.h5
larndH5="$outDir"/LARNDSIM/$(basename "$edepH5" .EDEPSIM.h5).LARNDSIM.h5

simulate_pixels.py --input_filename "$edepH5" --output_filename "$larndH5" \
    --detector_properties larnd-sim/larndsim/detector_properties/2x2.yaml \
    --pixel_layout larnd-sim/larndsim/pixel_layouts/multi_tile_layout-2.3.16.yaml \
    --response_file larnd-sim/larndsim/bin/response_44.npy \
    --light_lut_filename larnd-sim/larndsim/bin/lightLUT.npz \
    --light_det_noise_filename larnd-sim/larndsim/bin/light_noise-2x2-example.npy
