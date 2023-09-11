#!/usr/bin/env bash

# Run me from the root directory of 2x2_sim

set -o errexit

# This is the "default" container. It can be overridden by exporting
# ARCUBE_CONTAINER before running e.g. run_edep_sim.sh
export ARCUBE_RUNTIME="SHIFTER"
export ARCUBE_CONTAINER=mjkramer/sim2x2:genie_edep.3_04_00.20230620

# export ARCUBE_RUNTIME="SINGULARITY"
# export ARCUBE_CONTAINER=sim2x2_genie_edep.LFG_testing.20230228.v2.sif

export ARCUBE_DIR=$PWD
export ARCUBE_CONTAINER_DIR=$ARCUBE_DIR/admin/containers

pushd run-edep-sim
./install_edep_sim.sh
popd

pushd run-spill-build
./install_spill_build.sh
popd

pushd run-convert2h5
./install_convert2h5.sh
popd

pushd run-larnd-sim
./install_larnd_sim.sh
popd

pushd run-ndlar-flow
./install_ndlar_flow.sh
popd

pushd validation
./install_validation.sh
popd
