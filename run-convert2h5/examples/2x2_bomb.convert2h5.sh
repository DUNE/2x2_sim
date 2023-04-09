#!/usr/bin/env bash

export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_EDEP_NAME=2x2_bomb_test
export ARCUBE_OUT_NAME=2x2_bomb.convert2h5
export ARCUBE_INDEX=0

./run_convert2h5.sh
