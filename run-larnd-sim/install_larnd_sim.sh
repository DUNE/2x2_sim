#!/usr/bin/env bash

module load cudatoolkit         # 11.7
module load python              # 3.9-anaconda-2021.11

rm -rf larnd-sim larnd.venv

python -m venv larnd.venv/
source larnd.venv/bin/activate

# Might need to remove larnd-sim from this requirements file. DONE.
pip install -r requirements.txt
# exit

# If installation via requirements.txt doesn't work, the below should rebuild
# the venv. Ideally, install everything *except* larnd-sim using the
# requirements.txt, then just use the block at the bottom to install larnd-sim.

# pip install -U pip wheel setuptools
# pip install cupy-cuda11x

# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#installing-with-pip
( git clone https://github.com/DUNE/larnd-sim.git
  cd larnd-sim || exit
  # From the test_MiniRun3 branch
  git checkout 1315a6903efb9b57499c9d41a990faa7d32cb88a
  # HACK: Replace cupy with cupy-cuda11x (no longer necessary; setup.py is smarter now)
  # mv setup.py setup.py.orig
  # sed 's/cupy/cupy-cuda11x/' setup.py.orig > setup.py
  pip install . )
  # mv setup.py.orig setup.py )
