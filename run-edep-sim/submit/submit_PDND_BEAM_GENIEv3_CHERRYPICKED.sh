#!/usr/bin/env bash

FIRST_JOB=0
# LAST_JOB=200
LAST_JOB=0

TEMPLATE=$PWD/templates/batch_PDND_BEAM_GENIEv3_CHERRYPICKED_TEMPLATE.sh
THIS_GEOM=$PWD/geometry/Merged2x2MINERvA_noRock.gdml
OUT_TYPE=NuMI_RHC_CHERRY
OUTDIR_ROOT=$PWD/output/${OUT_TYPE}
DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/G18_10a_02_11a_FNALsmall.xml
EXP=5E17

source do_submit_edep-sim.sh
