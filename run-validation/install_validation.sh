#!/usr/bin/env bash

set -o errexit

module unload python 2>/dev/null
module load python/3.9-anaconda-2021.11

python -m venv validation.venv
source validation.venv/bin/activate
pip install --upgrade pip setuptools wheel

pip install h5py matplotlib numpy awkward
