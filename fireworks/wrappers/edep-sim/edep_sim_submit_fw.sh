#!/usr/bin/env bash

sbatch "$@" $(dirname $0)/edep_sim_job.sh
