#!/usr/bin/env bash

# Run me from the root directory of 2x2_sim

set -o errexit

# This is the "default" container. It can be overridden by exporting
# ARCUBE_CONTAINER before running e.g. run_edep_sim.sh
export ARCUBE_CONTAINER=mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2

pushd run-edep-sim
./install_edep_sim.sh
popd

pushd run-spill-build
./install_spill_build.sh
popd

pushd run-convert2h5
./install_convert2h5
popd

pushd run-larnd-sim
./install_larnd_sim.sh
popd
