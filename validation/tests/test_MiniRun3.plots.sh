#!/usr/bin/env bash

export ARCUBE_EDEP_NAME='test_MiniRun3.convert2h5'
export ARCUBE_LARND_NAME='test_MiniRun3.larnd'
export ARCUBE_FLOW_NAME='test_MiniRun3.flow'
export ARCUBE_OUT_NAME='test_MiniRun3.plots'
export ARCUBE_INDEX='0'

./run_validation.sh
