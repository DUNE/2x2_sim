#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.data.inc.sh

source load_mlreco.inc.sh

[ -z "$ARCUBE_FLOW2SUPERA_CONFIG" ] && export ARCUBE_FLOW2SUPERA_CONFIG="2x2_data"

outName=$(basename "$ARCUBE_CHARGE_FILE" .h5).LARCV.root
outFile=${tmpOutDir}/${outName}

inName=$(basename "$ARCUBE_CHARGE_FILE" .h5).FLOW.hdf5
inFile=${ARCUBE_FLOWDIR_BASE}/${relDir}/${inName}

config=$ARCUBE_FLOW2SUPERA_CONFIG

rm -f "$outFile"

run install/flow2supera/bin/run_flow2supera.py -o "$outFile" -c "$config" "$inFile"

mv "${outFile}" "${outDir}"

echo "Written to $(realpath "${outDir}/$(basename "$outFile")")"
