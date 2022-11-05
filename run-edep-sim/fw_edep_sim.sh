#!/usr/bin/env bash

echo hello bash

echo $ARCUBE_BASE
echo $ARCUBE_CHERRYPICK
echo $ARCUBE_DET_LOCATION
echo $ARCUBE_DK2NU_DIR
echo $ARCUBE_EDEP_MAC
echo $ARCUBE_EXPOSURE
echo $ARCUBE_GEOM
echo $ARCUBE_TUNE
echo $ARCUBE_XSEC_FILE
echo $ARCUBE_OUT_NAME
echo $ARCUBE_DK2NU_INDEX
echo $ARCUBE_SEED

source /environment             # provided by the container

# HACK: This will not wait for other tasks on the node to complete
# if [[ "$SLURM_LOCALID" == 0 ]]; then
#     monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
#     ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
# fi

seed=$ARCUBE_SEED
echo "Seed is $seed"

dk2nuIdx=$ARCUBE_DK2NU_INDEX
dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuFile=${dk2nuAll[$dk2nuIdx]}

outDir=$PWD/output/$ARCUBE_OUT_NAME

outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%07d" $seed)

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/tmp_bin/time      # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

export GXMLPATH=$PWD/flux            # contains GNuMIFlux.xml
maxPathFile=$PWD/maxpath/$(basename "$ARCUBE_GEOM" .gdml).$ARCUBE_TUNE.maxpath.xml
genieOutPrefix=$outDir/GENIE/$outName
mkdir -p "$(dirname "$genieOutPrefix")"

# HACK: gevgen_fnal hardcodes the name of the status file (unlike gevgen, which
# respects -o), so run it in a temporary directory. Need to get absolute paths.

dk2nuFile=$(realpath "$dk2nuFile")
ARCUBE_GEOM=$(realpath "$ARCUBE_GEOM")
ARCUBE_XSEC_FILE=$(realpath "$ARCUBE_XSEC_FILE")

tmpDir=$(mktemp -d)
pushd "$tmpDir"

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

mv genie-mcjob-0.status "$genieOutPrefix".status
popd
rmdir "$tmpDir"

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

edepRootFile=$outDir/EDEPSIM/${outName}.EDEPSIM.root
mkdir -p "$(dirname "$edepRootFile")"

edepCode="/generator/kinematics/rooTracker/input $genieFile"

run edep-sim -C -g "$ARCUBE_GEOM" -o "$edepRootFile" -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"

edepH5File=$outDir/EDEPSIM_H5/${outName}.EDEPSIM.h5
mkdir -p "$(dirname "$edepH5File")"

# run venv/bin/python3 "$LARND_SIM"/cli/dumpTree.py "$edepRootFile" "$edepH5File"
# run venv/bin/python3 dumpTree.py "$edepRootFile" "$edepH5File"
run python3 dumpTree.py "$edepRootFile" "$edepH5File"
