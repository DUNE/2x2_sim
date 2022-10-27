#!/usr/bin/env bash

export ARCUBE_CHERRYPICK=0
export ARCUBE_DET_LOCATION=ProtoDUNE-ND
export ARCUBE_DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
export ARCUBE_EDEP_MAC=macros/2x2_beam.mac
export ARCUBE_EXPOSURE=5E15
export ARCUBE_GEOM=geometry/Merged2x2MINERvA_noRock.gdml
# export ARCUBE_OUT_NAME=NuMI_RHC_CHERRY
export ARCUBE_TUNE=G18_10a_02_11a
export ARCUBE_XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/${ARCUBE_TUNE}_FNALsmall.xml

for ntasks in 64 128 192 256; do
    export ARCUBE_OUT_NAME=NuMI_RHC_${ntasks}tasks
    ./do_submit.sh --ntasks-per-node $ntasks -q debug -t 30
done
