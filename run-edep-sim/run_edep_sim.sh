#!/usr/bin/env bash

# Reload in Shifter if necessary
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
    exit
fi

source /environment             # provided by the container

## HACK: This will not wait for other tasks on the node to complete
# if [[ "$SLURM_LOCALID" == 0 ]]; then
#     monitorFile=monitor-$SLURM_JOBID.$SLURM_NODEID.txt
#     ./monitor.sh >logs/"$ARCUBE_OUT_NAME"/"$SLURM_JOBID"/"$monitorFile" &
# fi

# Start seeds at 1 instead of 0, just in case GENIE does something
# weird when given zero (e.g. use the current time)
# NOTE: We just use the fixed Edep default seed of
seed=$((1 + ARCUBE_INDEX))
echo "Seed is $seed"

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuCount=${#dk2nuAll[@]}
dk2nuIdx=$((globalIdx % dk2nuCount))
dk2nuFile=${dk2nuAll[$dk2nuIdx]}
echo "dk2nuIdx is $dk2nuIdx"
echo "dk2nuFile is $dk2nuFile"

outDir=$PWD/output/$ARCUBE_OUT_NAME
[ ! -z "${ARCUBE_OUTDIR_BASE}" ] && outDir=$ARCUBE_OUTDIR_BASE/run-edep-sim/output/$ARCUBE_OUT_NAME
outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
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
USE_MAXPATH=1
if [ ! -f $maxPathFile ]; then
    echo ""
    echo "WARNING!!! .maxpath.xml file not found. Is this what you intended???"
    echo "           I WILL CONTINUE WITH NO maxPathFile"
    echo ""
    USE_MAXPATH=0
fi

genieOutPrefix=$outDir/GENIE/$outName
mkdir -p "$(dirname "$genieOutPrefix")"

# HACK: gevgen_fnal hardcodes the name of the status file (unlike gevgen, which
# respects -o), so run it in a temporary directory. Need to get absolute paths.

dk2nuFile=$(realpath "$dk2nuFile")
ARCUBE_GEOM=$(realpath "$ARCUBE_GEOM")
ARCUBE_XSEC_FILE=$(realpath "$ARCUBE_XSEC_FILE")

tmpDir=$(mktemp -d)
pushd "$tmpDir"

rm -f "$genieOutPrefix".*

args_gevgen_fnal=( \
    -e "$ARCUBE_EXPOSURE" \
    -f "$dk2nuFile","$ARCUBE_DET_LOCATION" \
    -g "$ARCUBE_GEOM" \
    -L cm -D g_cm3 \
    --cross-sections "$ARCUBE_XSEC_FILE" \
    --tune "$ARCUBE_TUNE" \
    --seed "$seed" \
    -o "$genieOutPrefix" \
    )

[ "${USE_MAXPATH}" == 1 ] && args_gevgen_fnal+=( -m "$maxPathFile" )
[ ! -z "${ARCUBE_TOP_VOLUME}" ] && args_gevgen_fnal+=( -t "$ARCUBE_TOP_VOLUME" )
[ ! -z "${ARCUBE_FID_CUT_STRING}" ] && args_gevgen_fnal+=( -F "$ARCUBE_FID_CUT_STRING" )
[ ! -z "${ARCUBE_ZMIN}" ] && args_gevgen_fnal+=( -z "$ARCUBE_ZMIN" )

run gevgen_fnal "${args_gevgen_fnal[@]}"

mv genie-mcjob-0.status "$genieOutPrefix".status
popd
rmdir "$tmpDir"

run gntpc -i "$genieOutPrefix".0.ghep.root -f rootracker \
    -o "$genieOutPrefix".0.gtrac.root
# rm "$genieOutPrefix".0.ghep.root

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
rm -f "$edepRootFile"

edepCode="/generator/kinematics/rooTracker/input $genieFile
/edep/runId $ARCUBE_INDEX"

export ARCUBE_GEOM_EDEP=${ARCUBE_GEOM_EDEP:-$ARCUBE_GEOM}

run edep-sim -C -g "$ARCUBE_GEOM_EDEP" -o "$edepRootFile" -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"
