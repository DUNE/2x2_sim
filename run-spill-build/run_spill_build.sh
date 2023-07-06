#!/usr/bin/env bash

# root -l -b -q 'overlaySinglesIntoSpills.C("/global/cfs/cdirs/dune/users/mkramer/mywork/2x2_sim/run-edep-sim/output/MiniRun1_1E19_RHC_nu/EDEPSIM/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.root","/global/cfs/cdirs/dune/users/mkramer/mywork/2x2_sim/run-edep-sim/output/MiniRun1_1E19_RHC_rock/EDEPSIM/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.root","test_multiSpill.root",2E15,5E14)'

if [[ "$ARCUBE_RUNTIME" == "SHIFTER" ]]; then
    # Reload in Shifter
    if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
        shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
        exit
    fi

elif [[ "$ARCUBE_RUNTIME" == "SINGULARITY" ]]; then
    # Or reload in Singularity
    if [[ "$SINGULARITY_NAME" != "$ARCUBE_CONTAINER" ]]; then
        singularity exec -B $ARCUBE_DIR $ARCUBE_CONTAINER_DIR/$ARCUBE_CONTAINER /bin/bash "$0" "$@"
        exit
    fi

else
    echo "Unsupported \$ARCUBE_RUNTIME"
    exit
fi

# source /environment             # provided by the container
source $ARCUBE_DIR/admin/container_env.sh

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
nuName=$ARCUBE_NU_NAME.$(printf "%05d" "$globalIdx")
rockName=$ARCUBE_ROCK_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

inBaseDir=$PWD/../run-edep-sim/output
nuInDir=$inBaseDir/$ARCUBE_NU_NAME
rockInDir=$inBaseDir/$ARCUBE_ROCK_NAME

nuInFile=$nuInDir/EDEPSIM/${nuName}.EDEPSIM.root
rockInFile=$rockInDir/EDEPSIM/${rockName}.EDEPSIM.root

outDir=$PWD/output/$ARCUBE_OUT_NAME
mkdir -p "$outDir"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/../run-edep-sim/tmp_bin/time      # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

spillOutDir=$outDir/EDEPSIM_SPILLS
mkdir -p "$spillOutDir"

spillFile=$spillOutDir/${outName}.EDEPSIM_SPILLS.root
rm -f "$spillFile"

# run root -l -b -q \
#     -e "gInterpreter->AddIncludePath(\"/opt/generators/edep-sim/install/include/EDepSim\")" \
#     "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT)"

# HACK: We need to "unload" edep-sim; if it's in our LD_LIBRARY_PATH, we have to
# use the "official" edepsim-io headers, which force us to use the getters, at
# least when using cling(?). overlaySinglesIntoSpills.C directly accesses the
# fields. So we apparently must use headers produced by MakeProject, but that
# would lead to a conflict with the ones from the edep-sim installation. Hence
# we unload the latter. Fun. See makeLibTG4Event.sh

function libpath_remove {
  LD_LIBRARY_PATH=":$LD_LIBRARY_PATH:"
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":"/"::"}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":$1:"/}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//"::"/":"}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH#:}; LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}
}

libpath_remove /opt/generators/edep-sim/install/lib

# run root -l -b -q \
#     -e "gInterpreter->AddIncludePath(\"libTG4Event\")" \
#     "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT)"

# run root -l -b -q \
#     -e "gSystem->Load(\"libTG4Event/libTG4Event.so\")" \
#     "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT)"

run root -l -b -q \
    -e "gSystem->Load(\"libTG4Event/libTG4Event.so\")" \
    "overlaySinglesIntoSpillsSorted.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $globalIdx, $ARCUBE_NU_POT, $ARCUBE_ROCK_POT)"
