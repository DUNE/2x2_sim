#!/usr/bin/env bash

source /environment             # provided by the container

seed=$((RANDOM))
echo "Seed is $seed"

globalIdx=$((SLURM_NODEID*SLURM_NTASKS_PER_NODE + SLURM_LOCALID))
echo "globalIdx is $globalIdx"

dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuCount=${#dk2nuAll[@]}
dk2nuIdx=$((globalIdx % dk2nuCount))
dk2nuFile=${dk2nuAll[$dk2nuIdx]}
echo "dk2nuIdx is $dk2nuIdx"
echo "dk2nuFile is $dk2nuFile"

outDir=output/$ARCUBE_OUT_NAME
# Since each dk2nu file may be processed multiple times (with different seeds),
# append an identifier
outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%03d" $((dk2nuIdx / dk2nuCount)))
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"

run() {
    echo RUNNING "$@"
    tmp_bin/time --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

export GXMLPATH=flux            # contains GNuMIFlux.xml
maxPathFile=maxpath/$(basename "$ARCUBE_GEOM" .gdml).$ARCUBE_TUNE.maxpath.xml
genieOutPrefix=$outDir/GENIE/$outName
mkdir -p "$(dirname "$genieOutPrefix")"

run gevgen_fnal \
    -e "$ARCUBE_EXPOSURE" \
    -f "$dk2nuFile","$ARCUBE_DET_LOCATION" \
    -g "$ARCUBE_GEOM" \
    -m "$maxPathFile" \
    -L cm -D g_cm3 \
    --cross-sections "$ARCUBE_XSEC_FILE" \
    --tune "$ARCUBE_TUNE" \
    --seed "$seed" \
    -o "$genieOutPrefix"

run gntpc -i "$genieOutPrefix".0.ghep.root -f rootracker \
    -o "$genieOutPrefix".0.roo.root
rm "$genieOutPrefix".0.ghep.root

if [[ "$ARCUBE_CHERRYPICK" == 1 ]]; then
    run ./cherrypicker.py -i "$genieOutPrefix".0.roo.root \
        -o "$genieOutPrefix".0.roo.cherry.root
    genieFile="$genieOutPrefix".0.roo.cherry.root
else
    genieFile="$genieOutPrefix".0.roo.root
fi

rootCode='
auto t = (TTree*) _file0->Get("gRooTracker");
std::cout << t->GetEntries() << std::endl;'
nEvents=$(echo "$rootCode" | root -l -b "$genieFile" | tail -1)

edepRootFile=$outDir/EDEPSIM/${outName}_EDEPSIM.root
mkdir -p "$(dirname "$edepRootFile")"

edepCode="/generator/kinematics/rooTracker/input $genieFile"

run edep-sim -C -g "$ARCUBE_GEOM" -o "$edepRootFile" -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"

edepH5File=$outDir/EDEPSIM_H5/${outName}_EDEPSIM.h5
mkdir -p "$(dirname "$edepH5File")"

run venv/bin/python3 "$LARND_SIM"/cli/dumpTree.py "$edepRootFile" "$edepH5File"
