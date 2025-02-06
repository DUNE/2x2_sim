#!/usr/bin/env bash

#SBATCH --account=dune_g
#SBATCH --qos=regular
#SBATCH --constraint=gpu
#SBATCH --time=2:45:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=32

srun ./elifetime_ndlarflow_slurm_task.py fake_edepsim_inputs.txt 
