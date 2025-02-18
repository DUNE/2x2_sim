#!/bin/bash

#SBATCH -A dune                 # account to use for the job, '--account', '-A'
#SBATCH -J neutron_prod         # job name, '--job-name', '-J'
#SBATCH -C cpu                  # type of job (constraint can be 'cpu' or 'gpu'), '--constraint', '-C'
#SBATCH -t 60                   # amount of time requested for the job, '--time', 't'
#SBATCH -N 1                    # number of nodes, '--nodes', '-N'
#SBATCH -n 1                    # number of tasks '--ntasks', -n'
#SBATCH -c 4                    # number of cores per task, '--cpus-per-task', '-c'
#SBATCH -q regular              # type of quality-of-service (QOS), by default it is debug 

MY_SCRATCH_OUTDIR="$SCRATCH/grid_output"
mkdir -p $MY_SCRATCH_OUTDIR

NEVENTS=100000
PS_LIST='MyQGSP_BERT_ArHP'

shifter --image=mjkramer/sim2x2:ndlar011 -e NEVENTS=$NEVENTS -e PS_LIST=$PS_LIST -e TYPE=$SOURCE $SCRATCH/grid_scripts/run_edep_sim.sh

