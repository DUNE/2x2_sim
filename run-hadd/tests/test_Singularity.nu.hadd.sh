#!/usr/bin/env bash

export ARCUBE_DIR='/nfs/data41/dune/cuddandr/2x2_sim/'
export ARCUBE_RUNTIME='SINGULARITY'
export ARCUBE_CONTAINER_DIR='/nfs/data41/dune/cuddandr/2x2_sim/admin/containers'
export ARCUBE_CONTAINER='sim2x2_genie_edep.LFG_testing.20230228.v2.sif'
export ARCUBE_HADD_FACTOR='2'
export ARCUBE_IN_NAME='test_Singularity.nu'
export ARCUBE_OUT_NAME='test_Singularity.nu.hadd'
export ARCUBE_INDEX='0'

./run_hadd.sh
