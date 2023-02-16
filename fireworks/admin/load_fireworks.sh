#!/usr/bin/env bash
# source me

module load python
module load mongodb

source fw.venv/bin/activate

export FW_CONFIG_FILE=$(realpath fw_config/FW_config.yaml)
