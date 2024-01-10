#!/usr/bin/env bash

export ARCUBE_RUNTIME=SHIFTER
# export ARCUBE_CONTAINER=deeplearnphysics/larcv2:ub20.04-cuda11.3-cudnn8-pytorch1.10.0-larndsim-2022-11-03
## Above but with venv support:
export ARCUBE_CONTAINER=mjkramer/sim2x2:mlreco001

source ../util/reload_in_container.inc.sh

set -o errexit

# recommended by Jeremy
unset which

mkdir install
cd install

python3 -m venv --system-site-packages mlreco.venv
source mlreco.venv/bin/activate
pip3 install --upgrade pip setuptools wheel
# pip install 'ruamel.yaml<0.18.0' # for deprecated load()
pip install scikit-build # for SuperaAtomic
pip install scikit-learn # for flow2supera
pip install --upgrade torch_geometric # for mlreco

git clone -b v2_2_0 https://github.com/DeepLearnPhysics/larcv2.git
cd larcv2
source configure.sh
make -j16
cd ..

git clone -b v1.4.0 https://github.com/DeepLearnPhysics/SuperaAtomic.git
cd SuperaAtomic
git submodule update --init     # pybind11
pip install .
cd ..

git clone -b v1.2.0 https://github.com/DeepLearnPhysics/edep2supera.git
cd edep2supera
pip install .
cd ..

git clone https://github.com/YifanC/larpix_readout_parser.git
cd larpix_readout_parser
pip install .
cd ..

git clone -b main https://github.com/larpix/h5flow.git
cd h5flow
pip install .
cd ..

git clone -b v1.1.0 https://github.com/sindhu-ku/flow2supera.git
cd flow2supera
pip install .
cd ..

git clone https://github.com/facebookresearch/SparseConvNet.git
cd SparseConvNet
# These paths don't exist in the container
# They lead to `nvcc' being sought in the wrong place`
unset CUDATOOLKIT_HOME
unset CUDA_HOME
pip install .
cd ..

# commit 8103996
# git clone -b jw_dune_nd_lar https://github.com/chenel/lartpc_mlreco3d.git
git clone -b v2.9.2.4 https://github.com/DeepLearnPhysics/lartpc_mlreco3d.git

# git clone https://github.com/chenel/dune-nd-lar-reco.git
# the old yaml.load API has been removed
# sed -i 's/yaml.load(open(filename))/yaml.load(open(filename), yaml.Loader)/' \
#     dune-nd-lar-reco/load_helpers.py
