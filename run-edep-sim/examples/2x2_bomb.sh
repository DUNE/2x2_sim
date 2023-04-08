#!/usr/bin/env bash

export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_EDEP_MAC='macros/2x2_bomb.mac'
export ARCUBE_GEOM='geometry/arc2x2_sensLAr.gdml'
export ARCUBE_NEVENTS=100
export ARCUBE_OUT_NAME=2x2_bomb_test
export ARCUBE_INDEX=0

./run_edep_sim.sh
