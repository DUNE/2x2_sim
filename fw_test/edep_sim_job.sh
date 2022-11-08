#!/usr/bin/env bash
#SBATCH --account=dune
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --time=2:00:00
#SBATCH --ntasks-per-node=256

srun rlaunch rapidfire -w fworker_edep_sim.yaml
