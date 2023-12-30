#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

genieOutPrefix=${ARCUBE_OUTDIR_BASE}/run-genie/${ARCUBE_GENIE_NAME}/GENIE/${ARCUBE_GENIE_NAME}.$globalIdx
genieFile="$genieOutPrefix".GTRAC.root

rootCode='
auto t = (TTree*) _file0->Get("gRooTracker");
std::cout << t->GetEntries() << std::endl;'
nEvents=$(echo "$rootCode" | root -l -b "$genieFile" | tail -1)

edepRootFile=$tmpOutDir/${outName}.EDEPSIM.root
rm -f "$edepRootFile"

edepCode="/generator/kinematics/rooTracker/input $genieFile
/edep/runId $runNo"

# The geometry file is given relative to the root of 2x2_sim
export ARCUBE_GEOM_EDEP=$baseDir/${ARCUBE_GEOM_EDEP:-$ARCUBE_GEOM}

run edep-sim -C -g "$ARCUBE_GEOM_EDEP" -o "$edepRootFile" -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"

mkdir -p "$outDir"/EDEPSIM
mv "$edepRootFile" "$outDir"/EDEPSIM
