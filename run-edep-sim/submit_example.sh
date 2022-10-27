#!/usr/bin/env bash

export ARCUBE_CHERRYPICK=1
export ARCUBE_DET_LOCATION=ProtoDUNE-ND
export ARCUBE_DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
export ARCUBE_EDEP_MAC=macros/2x2_beam.mac
# export ARCUBE_EXPOSURE=5E17
export ARCUBE_EXPOSURE=1E17
export ARCUBE_GEOM=geometry/Merged2x2MINERvA_noRock.gdml
export ARCUBE_OUT_NAME=NuMI_RHC_CHERRY
export ARCUBE_TUNE=G18_10a_02_11a
export ARCUBE_XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/${ARCUBE_TUNE}_FNALsmall.xml

./do_submit.sh "$@"
