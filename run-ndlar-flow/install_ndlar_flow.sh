#!/usr/bin/env bash

set -o errexit

module load python/3.11

python -m venv flow.venv
source flow.venv/bin/activate
pip install --upgrade pip setuptools wheel

# install h5flow
git clone https://github.com/larpix/h5flow.git
cd h5flow
pip install -e .
cd ..

# install ndlar_flow
git clone -b develop https://github.com/larpix/ndlar_flow.git
cd ndlar_flow
pip install -e .
cd ..

datadir=ndlar_flow/data/proto_nd_flow

cp static/multi_tile_layout-2.4.16.yaml $datadir
cp static/runlist-2x2-mcexample.txt $datadir
cp static/light_module_desc-0.0.0.yaml $datadir

cp ../run-larnd-sim/larnd-sim/larndsim/detector_properties/2x2.yaml $datadir
