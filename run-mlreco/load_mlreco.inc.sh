#!/usr/bin/env bash

unset which

source install/mlreco.venv/bin/activate

pushd install/larcv2
source configure.sh
popd

export PYTHONPATH=$PWD/install/flow2supera/src:$PYTHONPATH

export PYTHONPATH=$PWD/install/lartpc_mlreco3d:$PYTHONPATH
