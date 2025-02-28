#!/bin/bash


#source_list=("AmBe" "DTG")
source_list=("AmBe")

# Create scratch output dir
MY_SCRATCH_OUTDIR="$SCRATCH/grid_output"
mkdir -p $MY_SCRATCH_OUTDIR

# export variables to configure your job 
export NEVENTS=5000
export PS_LIST='MyQGSP_BERT_ArHP'
export PROJECT_NAME='AmBe_Prod_V2'

# Create output dir 
export WORK_TOP_DIR="$SCRATCH/grid_workdir/${PROJECT_NAME}"
# Create workdir if it does not exist
mkdir -p $WORK_TOP_DIR
echo "Working top dir: ${WORK_TOP_DIR}"


export OUT_DIR_EDEPSIM="$SCRATCH/grid_output/${PROJECT_NAME}/EDEPSIM"
# Create output dir if it does not exist
mkdir -p $OUT_DIR_EDEPSIM 
echo "edepsim output dir: ${OUT_DIR_EDEPSIM}"

# set the number of jobs to submit 
for i in {0..50}
do
  for sc in "${source_list[@]}"
  do
    echo "Submitting job $i for ${sc} source"
    export SOURCE=$sc
    export JOB=$i
    sbatch shifter_run.slurm 
  done

done

