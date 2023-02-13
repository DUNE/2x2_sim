#!/usr/bin/env bash

source /environment             # provided by the container

# HACK: This will not wait for other tasks on the node to complete
if [[ "$SLURM_LOCALID" == 0 ]]; then
    monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
    ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
fi

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

outDir=$PWD/output/$ARCUBE_OUT_NAME
# Since each dk2nu file may be processed multiple times (with different seeds),
# append an identifier
outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%03d" $((globalIdx / dk2nuCount)))
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/tmp_bin/time      # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
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
    -o "$genieOutPrefix".0.gtrac.root
rm "$genieOutPrefix".0.ghep.root

if [[ "$ARCUBE_CHERRYPICK" == 1 ]]; then
    run ./cherrypicker.py -i "$genieOutPrefix".0.gtrac.root \
        -o "$genieOutPrefix".0.gtrac.cherry.root
    genieFile="$genieOutPrefix".0.gtrac.cherry.root
else
    genieFile="$genieOutPrefix".0.gtrac.root
fi

rootCode='
auto t = (TTree*) _file0->Get("gRooTracker");
std::cout << t->GetEntries() << std::endl;'
nEvents=$(echo "$rootCode" | root -l -b "$genieFile" | tail -1)

edepRootFile=$outDir/EDEPSIM/${outName}.EDEPSIM.root
mkdir -p "$(dirname "$edepRootFile")"

edepCode="/generator/kinematics/rooTracker/input $genieFile"

export ARCUBE_GEOM_EDEP=${ARCUBE_GEOM_EDEP:-$ARCUBE_GEOM}

run edep-sim -C -g "$ARCUBE_GEOM_EDEP" -o "$edepRootFile" -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"

edepH5File=$outDir/EDEPSIM_H5/${outName}.EDEPSIM.h5
mkdir -p "$(dirname "$edepH5File")"

# run venv/bin/python3 "$LARND_SIM"/cli/dumpTree.py "$edepRootFile" "$edepH5File"
# run venv/bin/python3 dumpTree.py "$edepRootFile" "$edepH5File"
run python3 dumpTree.py "$edepRootFile" "$edepH5File"
