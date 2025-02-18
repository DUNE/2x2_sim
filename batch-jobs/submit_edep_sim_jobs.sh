#!/bin/bash


#source_list=("AmBe" "DTG")
source_list=("AmBe")

for sc in "${source_list[@]}";do
    echo "Submitting job for ${sc} source"
    export SOURCE=$sc
    sbatch shifter_run.slurm 
done