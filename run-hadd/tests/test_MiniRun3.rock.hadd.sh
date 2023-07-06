#!/usr/bin/env bash

export ARCUBE_RUNTIME='SHIFTER'
export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_HADD_FACTOR='10'
export ARCUBE_IN_NAME='test_MiniRun3.rock'
export ARCUBE_OUT_NAME='test_MiniRun3.rock.hadd'
export ARCUBE_INDEX='0'

./run_hadd.sh
