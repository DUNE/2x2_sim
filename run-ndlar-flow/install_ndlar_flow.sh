#!/usr/bin/env bash

set -o errexit

module unload python 2>/dev/null
module load python/3.9-anaconda-2021.11

python -m venv flow.venv
source flow.venv/bin/activate
pip install --upgrade pip setuptools wheel

# install h5flow
git clone https://github.com/larpix/h5flow.git
cd h5flow
git checkout d2864e84d1bcd2553139373d2f39baab7a9bdfdf
pip install .
cd ..

# install ndlar_flow
git clone https://github.com/larpix/ndlar_flow.git
cd ndlar_flow
# used for first flow of MiniRun4
git checkout 9c7cb131223026cf43d151679391dab68176d4ee
pip install .
cd ..

datadir=ndlar_flow/data/proto_nd_flow

cp static/multi_tile_layout-2.4.16.yaml $datadir
cp static/runlist-2x2-mcexample.txt $datadir
cp static/light_module_desc-0.0.0.yaml $datadir

cp ../run-larnd-sim/larnd-sim/larndsim/detector_properties/2x2.yaml $datadir
