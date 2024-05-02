#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

source load_mlreco.inc.sh

outFile=${tmpOutDir}/${outName}.MLRECO_INF.hdf5
inName=${ARCUBE_IN_NAME}.${globalIdx}
inFile=${ARCUBE_OUTDIR_BASE}/run-mlreco/${ARCUBE_IN_NAME}/LARCV/${subDir}/${inName}.LARCV.root
config=2x2_full_chain_240403.cfg

tmpDir=$(mktemp -d)
mkdir "${tmpDir}/log_trash" "${tmpDir}/weight_trash"

sed "s!%TMPDIR%!${tmpDir}!g" "configs/${config}" > "${tmpDir}/${config}"

run python3 install/lartpc_mlreco3d/bin/run.py \
    "${tmpDir}/${config}" \
    --data_keys "$inFile" \
    --outfile "$outFile"

infOutDir=${outDir}/MLRECO_INF/${subDir}
mkdir -p "$infOutDir"
mv "$outFile" "$infOutDir"

rm -rf "$tmpDir"
