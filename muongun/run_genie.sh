#!/usr/bin/env bash

# run genmaxpath.sh first!

source /environment
source muongun_vars.inc.sh

dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuFile=${dk2nuAll[0]}

maxPathFile=$PWD/../run-edep-sim/maxpath/$(basename "$ARCUBE_GEOM" .gdml).$ARCUBE_TUNE.maxpath.xml

seed=0

time gevgen_fnal \
    -e "$ARCUBE_EXPOSURE" \
    -f "$dk2nuFile","$ARCUBE_DET_LOCATION" \
    -g "$ARCUBE_GEOM" \
    -m "$maxPathFile" \
    -L cm -D g_cm3 \
    --cross-sections "$ARCUBE_XSEC_FILE" \
    --tune "$ARCUBE_TUNE" \
    --seed "$seed" # \
    # -o "$genieOutPrefix"

gntpc -i gntp.0.ghep.root -f rootracker -o gntp.0.gtrac.root
