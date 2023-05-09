#!/usr/bin/env bash

set -o errexit

module load python

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
# feature_genie_stack (now merged into MiniRun3_dev; MiniRun3C tag)
git checkout 7c52150c14f2447b06aa2fd9ee9bee8d0b4dbf83
pip install .
cd ..

datadir=ndlar_flow/data/proto_nd_flow

cp static/multi_tile_layout-2.3.16.yaml $datadir
cp static/runlist-2x2-mcexample.txt $datadir
cp static/light_module_desc-0.0.0.yaml $datadir

cp ../run-larnd-sim/larnd-sim/larndsim/detector_properties/2x2.yaml $datadir
