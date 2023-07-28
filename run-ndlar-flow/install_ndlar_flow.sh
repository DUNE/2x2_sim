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
# used for first flow of MiniRun4
git checkout 627f5761dbe5405c24c2a85aa4af85a7cf659bea
pip install .
cd ..

datadir=ndlar_flow/data/proto_nd_flow

cp static/multi_tile_layout-2.3.16.yaml $datadir
cp static/runlist-2x2-mcexample.txt $datadir
cp static/light_module_desc-0.0.0.yaml $datadir

cp ../run-larnd-sim/larnd-sim/larndsim/detector_properties/2x2.yaml $datadir
