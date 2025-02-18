#!/bin/bash

#SBATCH -A dune                 # account to use for the job, '--account', '-A'
#SBATCH -J lm9_neutrons         # job name, '--job-name', '-J'
#SBATCH -C cpu                  # type of job (constraint can be 'cpu' or 'gpu'), '--constraint', '-C'
#SBATCH -t 00:10:00             # amount of time requested for the job, '--time', 't'
#SBATCH -N 1                    # number of nodes, '--nodes', '-N'
#SBATCH -n 1                    # number of tasks '--ntasks', -n'
#SBATCH --qos=regular
#SBATCH -c 8                    # number of cores per task, '--cpus-per-task', '-c'

MY_SCRATCH_OUTDIR="$SCRATCH/grid_output"
mkdir -p $MY_SCRATCH_OUTDIR

NEVENTS=1000
PS_LIST='QGSP_BIC'
ENERGY='0.05'

srun shifter --image=mjkramer/sim2x2:ndlar011 -e NEVENTS=$NEVENTS -e PS_LIST=$PS_LIST -e ENERGY=$ENERGY $SCRATCH/grid_scripts/run_edep_sim.sh