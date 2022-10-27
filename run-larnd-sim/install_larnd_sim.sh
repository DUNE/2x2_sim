#!/usr/bin/env bash

module load cudatoolkit         # 11.7
module load python              # 3.9-anaconda-2021.11

rm -rf larnd-sim venv

python -m venv venv/
source venv/bin/activate

pip install -U pip wheel setuptools

# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#installing-with-pip
( git clone https://github.com/DUNE/larnd-sim.git
  cd larnd-sim || exit
  # HACK: Replace cupy with cupy-cuda11x
  mv setup.py setup.py.orig
  sed 's/cupy/cupy-cuda11x/' setup.py.orig > setup.py
  pip install .
  mv setup.py.orig setup.py )

# The job needs dotlockfile
( git clone https://github.com/miquels/liblockfile.git
  cd liblockfile || exit
  ./configure
  make -j4 )
