#!/usr/bin/env bash

# root -l -b -q 'overlaySinglesIntoSpills.C("/global/cfs/cdirs/dune/users/mkramer/mywork/2x2_sim/run-edep-sim/output/MiniRun1_1E19_RHC_nu/EDEPSIM/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.root","/global/cfs/cdirs/dune/users/mkramer/mywork/2x2_sim/run-edep-sim/output/MiniRun1_1E19_RHC_rock/EDEPSIM/g4numiv6_minervame_me000z-200i_0_0001.000.EDEPSIM.root","test_multiSpill.root",2E15,5E14)'

# Reload in Shifter if necessary
image=docker:wilkinsonnu/nuisance_project:2x2_sim_prod
if [[ "$SHIFTER_IMAGEREQUEST" != "$image" ]]; then
    shifter --image=$image --module=none -- "$0" "$@"
    exit
fi

source /environment             # provided by the container

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

dk2nuAll=("$ARCUBE_DK2NU_DIR"/*.dk2nu)
dk2nuCount=${#dk2nuAll[@]}
dk2nuIdx=$((globalIdx % dk2nuCount))
dk2nuFile=${dk2nuAll[$dk2nuIdx]}
echo "dk2nuIdx is $dk2nuIdx"
echo "dk2nuFile is $dk2nuFile"

outName=$(basename "$dk2nuFile" .dk2nu).$(printf "%03d" $((globalIdx / dk2nuCount)))
echo "outName is $outName"

inBaseDir=$PWD/../run-edep-sim/output
nuInDir=$inBaseDir/$ARCUBE_NU_NAME
rockInDir=$inBaseDir/$ARCUBE_ROCK_NAME

nuInFile=$nuInDir/EDEPSIM/${outName}.EDEPSIM.root
rockInFile=$rockInDir/EDEPSIM/${outName}.EDEPSIM.root

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

run root -l -b -q \
    -e "gSystem->Load(\"libTG4Event/libTG4Event.so\")" \
    "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT)"
