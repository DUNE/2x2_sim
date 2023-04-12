#!/usr/bin/env bash

set -o errexit

module load python

python -m venv flow.venv
source flow.venv/bin/activate

# install h5flow
git clone https://github.com/larpix/h5flow.git
cd h5flow
git checkout d2864e84d1bcd2553139373d2f39baab7a9bdfdf
pip install .
cd ..

# install ndlar_flow
git clone https://github.com/larpix/ndlar_flow.git
cd ndlar_flow
git checkout 946336a19343bcd9a7ef5b4ef56a0c8be13c2fff
pip install .
cd ..

datadir=ndlar_flow/data/proto_nd_flow

cp static/multi_tile_layout-2.3.16.yaml $datadir
cp static/2x2.yaml $datadir
cp static/runlist-2x2-mcexample.txt $datadir
cp static/light_module_desc-0.0.0.yaml $datadir
