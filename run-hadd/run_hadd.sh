#!/usr/bin/env bash

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
