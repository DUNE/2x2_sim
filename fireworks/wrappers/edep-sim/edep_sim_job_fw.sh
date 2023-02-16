#!/usr/bin/env bash
#SBATCH --account=dune
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --time=2:00:00
#SBATCH --ntasks-per-node=256

fw_confdir=$(dirname $FW_CONFIG_FILE)

srun rlaunch rapidfire -w $fw_confdir/fworker_edep_sim.yaml
