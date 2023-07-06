#!/usr/bin/env bash

export ARCUBE_RUNTIME='SHIFTER'
export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_SPILL_NAME='test_MiniRun3.spill'
export ARCUBE_OUT_NAME='test_MiniRun3.convert2h5'
export ARCUBE_INDEX='0'

./run_convert2h5.sh
