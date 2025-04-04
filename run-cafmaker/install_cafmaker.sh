#!/usr/bin/env bash

export ARCUBE_RUNTIME=SHIFTER
export ARCUBE_CONTAINER=fermilab/fnal-wn-sl7:latest

source ../util/reload_in_container.inc.sh

set +o errexit

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup edepsim v3_2_0c -q e20:prof

mkdir install
cd install

git clone -b v4.8.1 https://github.com/DUNE/ND_CAFMaker.git
cd ND_CAFMaker

./build.sh
source ndcaf_setup.sh
make -j8

cd ../..

# Pre-compile
export ROOT_INCLUDE_PATH=$SQLITE_INC:$ROOT_INCLUDE_PATH
root -l -b -q -e ".L match_minerva.cpp+"

# Needed for match_minerva.cpp
wget https://portal.nersc.gov/project/dune/data/2x2/DB/RunsDB/releases/mx2x2runs_v0.2.sqlite
