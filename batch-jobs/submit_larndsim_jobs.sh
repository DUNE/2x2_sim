#!/bin/bash

# export variables to configure your job 
export PROJECT_NAME='AmBe_Prod_V1'

# Physics list 
export PS_LIST='MyQGSP_BERT_ArHP'

# Source type
export TYPE='AmBe'

echo "Project name: ${PROJECT_NAME}"

# Create output dir 
export WORK_TOP_DIR="$SCRATCH/grid_workdir/${PROJECT_NAME}/LARNDSIM_FLOW"
# Create workdir if it does not exist
mkdir -p $WORK_TOP_DIR
echo "Working top dir: ${WORK_TOP_DIR}"

export OUT_DIR_LARNDSIM="$SCRATCH/grid_output/${PROJECT_NAME}/LARNDSIM"
# Create output dir if it does not exist
mkdir -p $OUT_DIR_LARNDSIM 
echo "larndsim output dir: ${OUT_DIR_LARNDSIM}"

export OUT_DIR_FLOW="$SCRATCH/grid_output/${PROJECT_NAME}/FLOW"
# Create output dir if it does not exist
mkdir -p $OUT_DIR_FLOW 
echo "flow output dir: ${OUT_DIR_FLOW}"

# make a list of edep-sim files created for the project 
ls -d $SCRATCH/grid_output/$PROJECT_NAME/EDEPSIM/*.hdf5 > temp_list.txt 

JOB_NUM=0
for line in $(cat temp_list.txt); do
    echo "Submitting job for file: $line"
    echo "Which is job number ${JOB_NUM}"
    export OUT_FILE_HDF5=$line
    export JOB=$JOB_NUM 
    sbatch larndsim_run.slurm 
    ((JOB_NUM++))
done

rm temp_list.txt

# set the number of jobs to submit 
#for i in {0..1}
#do
#  for sc in "${source_list[@]}"
#  do
#    echo "Submitting job $i for ${sc} source"
#    export SOURCE=$sc
#    export JOB=$i
#    sbatch shifter_run.slurm 
#  done

#done
