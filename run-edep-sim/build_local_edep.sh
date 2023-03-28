#!/usr/bin/env bash

cd /global/cfs/cdirs/dune/users/mkramer/mywork/edep-sim/build
mkdir -p ../install
cmake -DCMAKE_INSTALL_PREFIX=../install ../
make -j16 && make install
