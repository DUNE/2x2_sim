#!/usr/bin/env bash

export ARCUBE_EXPOSURE=1E14
export ARCUBE_DET_LOCATION=ProtoDUNE-ND
export ARCUBE_DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
export ARCUBE_GEOM=$PWD/../run-edep-sim/geometry/Merged2x2MINERvA_justRock_sensShell.gdml
export ARCUBE_TUNE=G18_10a_02_11a
export ARCUBE_XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/${ARCUBE_TUNE}_FNALsmall.xml

export GXMLPATH=$PWD/../run-edep-sim/flux            # contains GNuMIFlux.xml
