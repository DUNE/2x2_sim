#!/usr/bin/env bash

export ARCUBE_DIR='/nfs/data41/dune/cuddandr/2x2_sim/'
export ARCUBE_RUNTIME='SINGULARITY'
export ARCUBE_CONTAINER_DIR='/nfs/data41/dune/cuddandr/2x2_sim/admin/containers'
export ARCUBE_CONTAINER='sim2x2_genie_edep.LFG_testing.20230228.v2.sif'
export ARCUBE_CHERRYPICK='0'
export ARCUBE_DET_LOCATION='ProtoDUNE-ND-Rock'
export ARCUBE_DK2NU_DIR='/nfs/data41/dune/cuddandr/2x2_inputs/dk2nu'
export ARCUBE_EDEP_MAC='macros/2x2_beam.mac'
export ARCUBE_EXPOSURE='1E15'
export ARCUBE_GEOM='geometry/Merged2x2MINERvA_v2/Merged2x2MINERvA_v2_justRock.gdml'
export ARCUBE_GEOM_EDEP='geometry/Merged2x2MINERvA_v2/Merged2x2MINERvA_v2_withRock.gdml'
export ARCUBE_TUNE='D22_22a_02_11b'
export ARCUBE_XSEC_FILE='/nfs/data41/dune/cuddandr/2x2_inputs/D22_22a_02_11b.all.LFG_testing.20230228.spline.xml'
export ARCUBE_OUT_NAME='test_Singularity.rock'

for i in $(seq 10); do
    ARCUBE_INDEX=$i ./run_edep_sim.sh &
done

wait
