#!/bin/bash

#SBATCH -A dune                 # account to use for the job, '--account', '-A'
#SBATCH -J neutron_prod         # job name, '--job-name', '-J'
#SBATCH -C gpu                  # type of job (constraint can be 'cpu' or 'gpu'), '--constraint', '-C'
#SBATCH -G 1                    # Number of GPUS 
#SBATCH -t 30                   # amount of time requested for the job, '--time', 't'
#SBATCH -N 1                    # number of nodes, '--nodes', '-N'
#SBATCH -n 1                    # number of tasks '--ntasks', -n'
#SBATCH -c 4                    # number of cores per task, '--cpus-per-task', '-c'
#SBATCH -q regular              # type of quality-of-service (QOS), by default it is debug 


srun run_larndsim.sh 
