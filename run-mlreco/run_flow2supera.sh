#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

source load_mlreco.inc.sh

outFile=${tmpOutDir}/${outName}.LARCV.root
inName=${ARCUBE_IN_NAME}.${globalIdx}
inFile=${ARCUBE_OUTDIR_BASE}/run-ndlar-flow/${ARCUBE_IN_NAME}/FLOW/${subDir}/${inName}.FLOW.hdf5
config=2x2

run install/flow2supera/bin/run_flow2supera.py -o "$outFile" -c "$config" "$inFile"

larcvOutDir=$outDir/LARCV/$subDir
mkdir -p "${larcvOutDir}"
mv "${outFile}" "${larcvOutDir}"
