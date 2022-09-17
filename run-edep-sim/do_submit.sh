#!/usr/bin/env bash

if [[ -z "$LARND_SIM" ]]; then
    echo 'Please set LARND_SIM to point to an installation of larnd-sim'
    echo '(we just need cli/dumpTree.py)'
    exit 1
fi

# The container is missing /usr/bin/time, which we use for outputting timing diagnostics
mkdir -p tmp_bin
cp -n /usr/bin/time tmp_bin

mkdir -p logs/"$ARCUBE_OUT_NAME"

sbatch -o logs/"$ARCUBE_OUT_NAME"/slurm-%j.out "$@" slurm_job.sh
