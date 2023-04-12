#!/usr/bin/env bash

set -o errexit

module load python

python -m venv validation.venv
source validation.venv/bin/activate
pip install --upgrade pip setuptools wheel

pip install h5py matplotlib numpy
