#!/usr/bin/env bash
# source me

module load python

source fw.venv/bin/activate

export FW_CONFIG_FILE=$(realpath config/FW_config.yaml)
