#!/usr/bin/env bash

module load cudatoolkit         # 11.7
module load python              # 3.9-anaconda-2021.11

rm -rf larnd-sim venv

python -m venv venv/
source venv/bin/activate

# Might need to remove larnd-sim from this requirements file
pip install -r pip/requirements.larnd-sim.txt
exit

# If installation via requirements.txt doesn't work, the below should rebuild
# the venv. Ideally, install everything *except* larnd-sim using the
# requirements.txt, then just use the block at the bottom to install larnd-sim.

pip install -U pip wheel setuptools

# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#installing-with-pip
( git clone https://github.com/DUNE/larnd-sim.git
  cd larnd-sim || exit
  # temperarily* checkout the feature branch for spill simulation
  # *soon to be merged into develop
  git checkout feature_spillSim
  # HACK: Replace cupy with cupy-cuda11x
  mv setup.py setup.py.orig
  sed 's/cupy/cupy-cuda11x/' setup.py.orig > setup.py
  pip install .
  mv setup.py.orig setup.py )
