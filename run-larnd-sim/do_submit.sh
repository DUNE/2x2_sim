#!/usr/bin/env bash

mkdir -p logs/"$ARCUBE_OUT_NAME"

sbatch -o logs/"$ARCUBE_OUT_NAME"/slurm-%j.out "$@" slurm_job.sh
