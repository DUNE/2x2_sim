#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

nuName=$ARCUBE_NU_NAME.$globalIdx
rockName=$ARCUBE_ROCK_NAME.$globalIdx
echo "outName is $outName"

# inBaseDir=$ARCUBE_OUTDIR_BASE/run-edep-sim/output
inBaseDir=$ARCUBE_OUTDIR_BASE/run-hadd/output
nuInDir=$inBaseDir/$ARCUBE_NU_NAME
rockInDir=$inBaseDir/$ARCUBE_ROCK_NAME

nuInFile=$nuInDir/EDEPSIM/${nuName}.EDEPSIM.root
rockInFile=$rockInDir/EDEPSIM/${rockName}.EDEPSIM.root

spillFile=$tmpOutDir/${outName}.EDEPSIM_SPILLS.root
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

libpath_remove /opt/generators/edep-sim/install/lib

[ -z "${ARCUBE_SPILL_POT}" ] && export ARCUBE_SPILL_POT=5e13
[ -z "${ARCUBE_SPILL_PERIOD}" ] && export ARCUBE_SPILL_PERIOD=1.2

if [[ "$ARCUBE_USE_GHEP_POT" == "1" ]]; then
  read -r ARCUBE_NU_POT < "$nuInDir"/POT/"$nuName".pot
  read -r ARCUBE_ROCK_POT < "$rockInDir"/POT/"$rockName".pot
fi

# run root -l -b -q \
#     -e "gInterpreter->AddIncludePath(\"libTG4Event\")" \
#     "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT, $ARCUBE_SPILL_POT)"

# run root -l -b -q \
#     -e "gSystem->Load(\"libTG4Event/libTG4Event.so\")" \
#     "overlaySinglesIntoSpills.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_NU_POT, $ARCUBE_ROCK_POT, $ARCUBE_SPILL_POT)"

# LIBTG4EVENT_DIR is provided by the podman-built containers
# If unset, fall back to the local build provided by install_spill_build.sh
LIBTG4EVENT_DIR=${LIBTG4EVENT_DIR:-libTG4Event}

run root -l -b -q \
    -e "gSystem->Load(\"$LIBTG4EVENT_DIR/libTG4Event.so\")" \
    "overlaySinglesIntoSpillsSorted.C(\"$nuInFile\", \"$rockInFile\", \"$spillFile\", $ARCUBE_INDEX, $ARCUBE_NU_POT, $ARCUBE_ROCK_POT, $ARCUBE_SPILL_POT, $ARCUBE_SPILL_PERIOD)"

mkdir -p "$outDir/EDEPSIM_SPILLS"
mv "$spillFile" "$outDir/EDEPSIM_SPILLS"
