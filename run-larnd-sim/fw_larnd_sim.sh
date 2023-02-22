#!/usr/bin/env bash

# HACK: This will not wait for other tasks on the node to complete
# if [[ "$SLURM_LOCALID" == 0 ]]; then
#     monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
#     ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
# fi

source venv/bin/activate

outDir=../run-edep-sim/output/$ARCUBE_OUT_NAME
mkdir -p "$outDir"/LARNDSIM

seed=$ARCUBE_SEED

dk2nuIdx=$ARCUBE_DK2NU_INDEX
dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuFile=${dk2nuAll[$dk2nuIdx]}

outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%07d" $seed)
input=$outDir/EDEPSIM_H5/$outName.EDEPSIM.h5
output=$outDir/LARNDSIM/$outName.LARNDSIM.h5
timeFile=$outDir/TIMING/$outName.time

# NOTE: THE CONVERSION OF THE EDEPSIM.ROOT FILE TO H5 SHOULD BE DONE HERE!
#       IT HAS BEEN REMOVED FROM THE RUN-EDEPSIM STAGE OF THE SIMULATION.
# python convert_edepsim_roottoh5.py --input_files edep-sim_*.root --output_file edep-sim.h5 --spill_period 1.2E6

/usr/bin/time --append -f "larnd-sim %P %M %E" -o "$timeFile" \
    simulate_pixels.py --input_filename "$input" \
    --output_filename "$output" \
    --detector_properties larnd-sim/larndsim/detector_properties/2x2.yaml \
    --pixel_layout larnd-sim/larndsim/pixel_layouts/multi_tile_layout-2.3.16.yaml \
    --response_file larnd-sim/larndsim/bin/response_44.npy \
    --light_lut_filename larnd-sim/larndsim/bin/lightLUT.npz \
    --light_det_noise_filename larnd-sim/larndsim/bin/light_noise-2x2-example.npy
