#!/usr/bin/env bash

# Reload in Shifter if necessary
if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image="$ARCUBE_CONTAINER" --module=none -- "$0" "$@"
    exit
fi

source /environment             # provided by the container

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outDir=$PWD/../run-edep-sim/output/$ARCUBE_OUT_NAME
outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/../run-edep-sim/tmp_bin/time # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

inDir=$PWD/../run-edep-sim/output/$ARCUBE_IN_NAME
tmpfile=$(mktemp)

for i in $(seq 0 $((ARCUBE_HADD_FACTOR - 1))); do
    inIdx=$((ARCUBE_INDEX*ARCUBE_HADD_FACTOR + i))
    inName=$ARCUBE_IN_NAME.$(printf "%05d" "$inIdx")
    inFile="$inDir"/EDEPSIM/"$inName".EDEPSIM.root
    echo "$inFile" >> "$tmpfile"
done

outFile=$outDir/EDEPSIM/${outName}.EDEPSIM.root
mkdir -p "$(dirname "$outFile")"
rm -f "$outFile"

run hadd "$outFile" "@$tmpfile"

rm "$tmpfile"
