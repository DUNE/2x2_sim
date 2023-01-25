#!/usr/bin/env bash

# HACK: This will not wait for other tasks on the node to complete
if [[ "$SLURM_LOCALID" == 0 ]]; then
    monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
    ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
fi

# Just in case, to avoid a rush for the lockfile
sleep $((RANDOM % 20))

source venv/bin/activate

outDir=../run-edep-sim/output/${ARCUBE_OUT_NAME}/LARNDSIM
mkdir -p "$outDir"

inFile=input/${ARCUBE_OUT_NAME}/input.list

dotlockfile=liblockfile/dotlockfile

while read -r input; do
    outName=$(basename "$input" .EDEPSIM.h5)

    [[ -e "$outDir/$outName.lock" ]] && continue
    [[ -e "$outDir/$outName.time" ]] && continue
    $dotlockfile -r 0 "$outDir/$outName.lock" || continue

    echo FILE-START "$(date)"

    time /usr/bin/time -f "%P %M %E" -o "$outDir/$outName.time" \
        simulate_pixels.py --input_filename "$input" \
        --output_filename "$outDir/$outName.LARNDSIM.h5" \
        --detector_properties larnd-sim/larndsim/detector_properties/2x2.yaml \
        --pixel_layout larnd-sim/larndsim/pixel_layouts/multi_tile_layout-2.3.16.yaml \
        --response_file larnd-sim/larndsim/bin/response_44.npy \
        --light_lut_filename larnd-sim/larndsim/bin/lightLUT.npz \
        --light_det_noise_filename larnd-sim/larndsim/bin/light_noise-2x2-example.npy

    echo FILE-END "$(date)"

    rm -f "$outDir/$outName.lock"
done < "$inFile"
