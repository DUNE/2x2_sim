#!/usr/bin/env bash

export ARCUBE_RUNTIME='SHIFTER'
export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_NU_NAME='test_MiniRun3.nu.hadd'
export ARCUBE_NU_POT='1E16'
export ARCUBE_ROCK_NAME='test_MiniRun3.rock.hadd'
export ARCUBE_ROCK_POT='1E16'
export ARCUBE_OUT_NAME='test_MiniRun3.spill'
export ARCUBE_INDEX='0'

./run_spill_build.sh
