#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh

cd install/ND_CAFMaker
source ndcaf_setup.sh
cd ../..

# Must go after ndcaf_setup.sh
source ../util/init.inc.sh

outFile=${tmpOutDir}/${outName}.CAF.root
flatOutFile=${tmpOutDir}/${outName}.CAF.flat.root
cfgFile=$(mktemp --suffix .cfg)

# Compulsory arguments.
args_gen_cafmaker_cfg=( \
    --base-dir "$ARCUBE_OUTDIR_BASE" \
    --mlreco-name "$ARCUBE_MLRECO_NAME" \
    --caf-path "$outFile" \
    --cfg-file "$cfgFile" \
    --file-id "$ARCUBE_INDEX" \
    )

[ -n "${ARCUBE_GHEP_NU_NAME}" ] && args_gevgen_fnal+=( --ghep-nu-name "$ARCUBE_GHEP_NU_NAME" )
[ -n "${ARCUBE_GHEP_ROCK_NAME}" ] && args_gevgen_fnal+=( --ghep-rock-name "$ARCUBE_GHEP_ROCK_NAME" )
[ -n "${ARCUBE_MINERVA_NAME}" ] && args_gevgen_fnal+=( --minerva-name "$ARCUBE_MINERVA_NAME" )
[ -n "${ARCUBE_TMSRECO_NAME}" ] && args_gevgen_fnal+=( --tmsreco-name "$ARCUBE_TMSRECO_NAME" )
[ -n "${ARCUBE_HADD_FACTOR}" ] && args_gevgen_fnal+=( --hadd-factor "$ARCUBE_HADD_FACTOR" )

./gen_cafmaker_cfg.py "${args_gen_cafmaker_cfg[@]}"

echo ===================
cat "$cfgFile"
echo ===================

run makeCAF "--fcl=$cfgFile"

cafOutDir=$outDir/CAF/$subDir
flatCafOutDir=$outDir/CAF.flat/$subDir
mkdir -p "$cafOutDir" "$flatCafOutDir"
mv "$outFile" "$cafOutDir"
mv "$flatOutFile" "$flatCafOutDir"

rm "$cfgFile"
