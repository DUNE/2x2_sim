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
[ ! -z "${ARCUBE_OUTDIR_BASE}" ] && outDir=$ARCUBE_OUTDIR_BASE/run-edep-sim/output/$ARCUBE_OUT_NAME
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
[ ! -z "${ARCUBE_OUTDIR_BASE}" ] && inDir=$ARCUBE_OUTDIR_BASE/run-edep-sim/output/$ARCUBE_IN_NAME
tmpfile=$(mktemp)
tmpfileghep=$(mktemp)

for i in $(seq 0 $((ARCUBE_HADD_FACTOR - 1))); do
    inIdx=$((ARCUBE_INDEX*ARCUBE_HADD_FACTOR + i))
    inName=$ARCUBE_IN_NAME.$(printf "%05d" "$inIdx")
    inFile="$inDir"/EDEPSIM/"$inName".EDEPSIM.root
    if [[ "$ARCUBE_USE_GHEP_POT" == "1" ]]; then
        if [ -f $inFile ]; then
            ghepFile=${inFile/EDEPSIM/GENIE}
            ghepFile=${ghepFile/EDEPSIM/0.ghep}
            echo "$ghepFile" >> "$tmpfileghep"
        else
            continue
        fi
    fi
    echo "$inFile" >> "$tmpfile"
done


if [[ "$ARCUBE_USE_GHEP_POT" == "1" ]]; then
    function libpath_remove {
      LD_LIBRARY_PATH=":$LD_LIBRARY_PATH:"
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":"/"::"}
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":$1:"/}
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH//"::"/":"}
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH#:}; LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}
    }

    libpath_remove /opt/generators/GENIE/R-3_04_00/lib

    potFile=$outDir/POT/${outName}.pot
    mkdir -p "$(dirname "$potFile")"
    rm -f "$potFile"

    run ./getGhepPOT.exe $tmpfileghep $potFile
    rm "$tmpfileghep"
fi


outFile=$outDir/EDEPSIM/${outName}.EDEPSIM.root
mkdir -p "$(dirname "$outFile")"
rm -f "$outFile"

run hadd "$outFile" "@$tmpfile"

rm "$tmpfile"
