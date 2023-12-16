#!/usr/bin/env bash

# run me in fnal sl7 container

source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup edepsim v3_2_0c -q e20:prof

git clone https://github.com/DUNE/ND_CAFMaker.git
cd ND_CAFMaker
sed -i 's/CXXFLAGS = /CXXFLAGS = -DDISABLE_TMS /' Makefile
./build.sh
make -j8
