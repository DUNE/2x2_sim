#!/usr/bin/env bash

ARCUBE_CONTAINER=mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2

# Reload in Shifter if necessary
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
    exit
fi

source environment_local.sh

rm -rf local
mkdir -p local/install
cd local

git clone https://github.com/jbeder/yaml-cpp.git
mkdir yaml-cpp/build
pushd yaml-cpp/build
cmake -DCMAKE_INSTALL_PREFIX=../../install ..
make -j16 && make install
popd

git clone https://github.com/DeepLearnPhysics/DLPGenerator
pushd DLPGenerator
source setup.sh
make -j16
popd

# git clone -b feat-mpvmpr https://github.com/drinkingkazu/edep-sim.git
git clone https://github.com/lbl-neutrino/edep-sim.git
pushd edep-sim
git checkout 5095fc38001d8115fa6827080a085d896d294112
cd build
cmake -DCMAKE_INSTALL_PREFIX=../../install ..
make -j16
make install
popd
