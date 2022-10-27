#!/usr/bin/env bash
#SBATCH --account=dune_g
#SBATCH --qos=regular
#SBATCH --constraint=gpu
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=32

# https://docs.nersc.gov/systems/perlmutter/running-jobs/#1-node-4-tasks-4-gpus-1-gpu-visible-to-each-task
export SLURM_CPU_BIND="cores"

# NOTE: Beginning with 22.05, srun will not inherit the --cpus-per-task value
# requested by salloc or sbatch. It must be requested again with the call to
# srun or set with the SRUN_CPUS_PER_TASK environment variable if desired for
# the task(s). (WTF?!??!)

export SRUN_CPUS_PER_TASK="$SLURM_CPUS_PER_TASK"

logDir=logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"
mkdir -p "$logDir"

echo JOB-START "$(date)"

srun -o "$logDir"/output-%j.%t.txt ./slurm_task.sh

echo JOB-END "$(date)"
