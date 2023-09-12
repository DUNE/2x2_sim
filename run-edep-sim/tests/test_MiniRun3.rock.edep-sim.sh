#!/usr/bin/env bash

export ARCUBE_RUNTIME='SHIFTER'
export ARCUBE_CONTAINER='mjkramer/sim2x2:genie_edep.LFG_testing.20230228.v2'
export ARCUBE_CHERRYPICK='0'
export ARCUBE_DET_LOCATION='ProtoDUNE-ND-Rock'
export ARCUBE_DK2NU_DIR='/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409'
export ARCUBE_EDEP_MAC='macros/2x2_beam.mac'
export ARCUBE_EXPOSURE='1E15'
export ARCUBE_GEOM='geometry/Merged2x2MINERvA_v2/Merged2x2MINERvA_v2_justRock.gdml'
export ARCUBE_GEOM_EDEP='geometry/Merged2x2MINERvA_v2/Merged2x2MINERvA_v2_withRock.gdml'
export ARCUBE_TUNE='D22_22a_02_11b'
export ARCUBE_XSEC_FILE='/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/D22_22a_02_11b.all.LFG_testing.20230228.spline.xml'
export ARCUBE_OUT_NAME='test_MiniRun3.rock'

for i in $(seq 0 9); do
    ARCUBE_INDEX=$i ./run_edep_sim.sh &
done

wait
