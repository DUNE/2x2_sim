#!/usr/bin/env bash
#SBATCH --account=dune_g
#SBATCH --qos=regular
#SBATCH --constraint=gpu
#SBATCH --time=2:00:00
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --cpus-per-task=32

srun rlaunch rapidfire -w fworker_larnd_sim.yaml