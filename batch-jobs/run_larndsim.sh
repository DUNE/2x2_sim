#!/bin/bash

echo "Printing gpu details..."
nvidia-smi 


echo "Loading libraries..."
module unload python 2>/dev/null
module unload cudatoolkit 2>/dev/null
## CUDA 12.2 makes us crash :(
# module load cudatoolkit/12.2
module load cudatoolkit/11.7
module load python/3.11

export TOP_DIR='/pscratch/sd/l/lmlepin/2x2_sim_develop/2x2_sim'
source $TOP_DIR/util/init.inc.sh
source $TOP_DIR/run-larnd-sim/larnd.venv/bin/activate


# Create working directory
export WORK_DIR="${WORK_TOP_DIR}/${TYPE}_${PROJECT_NAME}_${JOB}"
mkdir -p $WORK_DIR


export OUT_FILE_LARNDSIM="2x2_${PS_LIST}_${TYPE}_${PROJECT_NAME}_${JOB}.LARNDSIM.hdf5"

cd $WORK_DIR

# This will create the larnd-sim directly into the output directory 
echo "Running larnd-sim..."
python3 ${TOP_DIR}/run-larnd-sim/larnd-sim/cli/simulate_pixels.py --config 2x2_mpvmpr --input_filename ${OUT_FILE_HDF5} --output_filename ${OUT_FILE_LARNDSIM}

# deactivate larnd-sim venv and activate nd-flow venv 
deactivate
source $TOP_DIR/run-ndlar-flow/flow.venv/bin/activate

export FLOW_TOP_DIR="${TOP_DIR}/run-ndlar-flow/ndlar_flow"



# charge workflows
workflow1="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/charge/charge_event_building.yaml"
workflow2="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/charge/charge_event_reconstruction.yaml"
workflow3="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/combined/combined_reconstruction.yaml"
workflow4="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/charge/prompt_calibration.yaml"
workflow5="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/charge/final_calibration.yaml"

# light workflows
workflow6="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/light/light_event_building_mc.yaml"
workflow7="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/light/light_event_reconstruction.yaml"

# charge-light trigger matching
workflow8="${FLOW_TOP_DIR}/yamls/proto_nd_flow/workflows/charge/charge_light_assoc.yaml"

OUT_FILE_FLOW="2x2_${PS_LIST}_${TYPE}_${PROJECT_NAME}_${JOB}.FLOW.hdf5"

echo "Running flow..."
cd $FLOW_TOP_DIR

h5flow -c $workflow1 $workflow2 $workflow3 $workflow4 $workflow5\
       -i "$WORK_DIR/$OUT_FILE_LARNDSIM" -o "$OUT_DIR_FLOW/$OUT_FILE_FLOW"

h5flow -c $workflow6 $workflow7\
       -i "$WORK_DIR/$OUT_FILE_LARNDSIM" -o "$OUT_DIR_FLOW/$OUT_FILE_FLOW"

#h5flow -c $workflow8\
#       -i "$WORK_DIR/$OUT_FILE_LARNDSIM" -o "$OUT_DIR_FLOW/$OUT_FILE_FLOW"

cd $WORK_DIR

# Move products to output directories
mv $OUT_FILE_LARNDSIM $OUT_DIR_LARNDSIM
