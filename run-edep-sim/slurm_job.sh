#!/usr/bin/env bash
#SBATCH --image=docker:wilkinsonnu/nuisance_project:2x2_sim_prod
#SBATCH --module=none
#SBATCH --account=dune
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128

# NOTE: Each CPU-only node has 2 sockets, 64 cores/socket, 2 threads/core => 256
# threads in theory. Available memory is 512 GB. GENIE requires about 1 GB. In
# theory, we should be able to use 256 tasks, but start with 128

# NOTE: --module=none is needed to avoid loading Cray MPICH which breaks
# software built against older GLIBCs

logDir=logs/$ARCUBE_OUT_NAME/$SLURM_JOBID
mkdir -p "$logDir"

# Couldn't get this to work, see top of slurm_task.sh instead
# https://bugs.schedmd.com/show_bug.cgi?id=11863
# srun --overlap --exact --ntasks-per-node=1 --ntasks="$SLURM_NNODES" \
#     -o "$logDir"/monitor-%j.%t.out ./monitor.sh &

# try --cpu-bind=cores?
srun -o "$logDir"/output-%j.%t.txt shifter ./slurm_task.sh
