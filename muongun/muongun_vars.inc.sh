#!/usr/bin/env bash

# 1E14 POT ~ 750 events (for DET_NAME ProtoDUNE-ND, not -Rock)
# export ARCUBE_EXPOSURE=1E14
# 2E13 POT ~ 600 events (for ProtoDUNE-ND-Rock); 17 events that actually enter the cavern (XXX CHECK IF REASONABLE)
export ARCUBE_EXPOSURE=2E13
export ARCUBE_DET_LOCATION=ProtoDUNE-ND-Rock
export ARCUBE_DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
# export ARCUBE_GEOM=$PWD/../run-edep-sim/geometry/Merged2x2MINERvA_justRock_sensShell.gdml
export ARCUBE_GEOM=$PWD/../run-edep-sim/geometry/Merged2x2MINERvA_justRock_sensWaterHall.gdml
export ARCUBE_TUNE=G18_10a_02_11a
export ARCUBE_XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/${ARCUBE_TUNE}_FNALsmall.xml
# export ARCUBE_EDEP_MAC=$PWD/../run-edep-sim/macros/2x2_beam.mac
export ARCUBE_EDEP_MAC=$PWD/2x2_beam4muongun.mac

export GXMLPATH=$PWD/../run-edep-sim/flux            # contains GNuMIFlux.xml
