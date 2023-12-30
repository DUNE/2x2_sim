#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

inDir=${ARCUBE_OUTDIR_BASE}/run-edep-sim/$ARCUBE_IN_NAME
tmpfile=$(mktemp)
tmpfileghep=$(mktemp)

for i in $(seq 0 $((ARCUBE_HADD_FACTOR - 1))); do
    inIdx=$((ARCUBE_INDEX*ARCUBE_HADD_FACTOR + i))
    inName=$ARCUBE_IN_NAME.$(printf "%05d" "$inIdx")
    inFile="$inDir"/EDEPSIM/"$inName".EDEPSIM.root
    if [[ "$ARCUBE_USE_GHEP_POT" == "1" ]]; then
        if [ -f "$inFile" ]; then
            ghepInName=${inName/.edep./.genie.}
            ghepFile=${ARCUBE_OUTDIR_BASE}/run-genie/${ghepInName}/GENIE/${ghepInName}.${globalIdx}.GHEP.root
            echo "$ghepFile" >> "$tmpfileghep"
        else
            continue
        fi
    fi
    echo "$inFile" >> "$tmpfile"
done


if [[ "$ARCUBE_USE_GHEP_POT" == "1" ]]; then
    libpath_remove /opt/generators/GENIE/R-3_04_00/lib

    potFile=$outDir/POT/${outName}.pot
    mkdir -p "$(dirname "$potFile")"
    rm -f "$potFile"

    run ./getGhepPOT.exe "$tmpfileghep" "$potFile"
    rm "$tmpfileghep"
fi


outFile=$tmpOutDir/${outName}.EDEPSIM.root
rm -f "$outFile"

run hadd "$outFile" "@$tmpfile"

rm "$tmpfile"

mkdir -p "$outDir/EDEPSIM/$subDir"
mv "$outFile" "$outDir/EDEPSIM/$subDir"
