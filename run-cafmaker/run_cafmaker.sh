#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh

cd install/ND_CAFMaker
source ndcaf_setup.sh
cd ../..

# Must go after ndcaf_setup.sh
source ../util/init.inc.sh

outFile=${tmpOutDir}/${outName}.CAF.root
cfgFile=$(mktemp --suffix .cfg)

./gen_cafmaker_cfg.py \
    --base-dir "$ARCUBE_OUTDIR_BASE" \
    --ghep-nu-name "$ARCUBE_GHEP_NU_NAME" \
    --ghep-rock-name "$ARCUBE_GHEP_ROCK_NAME" \
    --mlreco-name "$ARCUBE_MLRECO_NAME" \
    --minerva-name "$ARCUBE_MINERVA_NAME" \
    --caf-path "$outFile" \
    --cfg-file "$cfgFile" \
    --file-id "$ARCUBE_INDEX"

echo ===================
cat "$cfgFile"
echo ===================

run makeCAF "--fcl=$cfgFile"

cafOutDir=$outDir/CAF/$subDir
mkdir -p "$cafOutDir"
mv "$outFile" "$cafOutDir"

rm "$cfgFile"
