#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

source load_mlreco.inc.sh

outFile=${tmpOutDir}/${outName}.MLRECO_ANALYSIS.hdf5
inName=${ARCUBE_IN_NAME}.${globalIdx}
inFile=${ARCUBE_OUTDIR_BASE}/run-mlreco/${ARCUBE_IN_NAME}/LARCV/${subDir}/${inName}.LARCV.root
config=2x2_full_chain_240819.cfg

tmpDir=$(mktemp -d)
mkdir "${tmpDir}/log_trash" 

sed "s!%TMPDIR%!${tmpDir}!g" "configs/${config}" > "${tmpDir}/${config}"

run python3 install/spine/bin/run.py \
    --config "${tmpDir}/${config}" \
    --source "$inFile" \
    --output "$outFile"


infOutDir=${outDir}/MLRECO_ANALYSIS/${subDir}
mkdir -p "$infOutDir"
mv "$outFile" "$infOutDir"

rm -rf "$tmpDir"
