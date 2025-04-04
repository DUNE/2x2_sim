#!/usr/bin/env bash

export ARCUBE_CONTAINER=${ARCUBE_CONTAINER:-fermilab/fnal-wn-sl7:latest}

source ../util/reload_in_container.inc.sh

cd install/ND_CAFMaker
set +o errexit
source ndcaf_setup.sh
set -o errexit
cd ../..

# Must go after ndcaf_setup.sh
source ../util/init.data.inc.sh
# Prevent excessive memory use
export OMP_NUM_THREADS=1
outName=$(basename "$ARCUBE_CHARGE_FILE" .h5)
outFile=${tmpOutDir}/${outName}.CAF.root
flatOutFile=${tmpOutDir}/${outName}.CAF.flat.root

tmpDir=$(mktemp -d)

cfgFile="$tmpDir/cafmaker.cfg"

spinePath=${ARCUBE_SPINE_DIR_BASE}/${relDir}/$(basename "$ARCUBE_CHARGE_FILE" .h5).MLRECO_SPINE.hdf5
pandoraPath=${ARCUBE_PANDORA_DIR_BASE}/${relDir}/LAR_RECO_ND/$(basename "$ARCUBE_CHARGE_FILE" .h5).LAR_RECO_ND.root

# Compulsory arguments regardless of use case.
args_gen_cafmaker_cfg=( \
    --caf-path "$outFile" \
    --cfg-file "$cfgFile" \
    --spine-path "$spinePath" \
    --pandora-path "$pandoraPath" \
    )

if [[ -n "$ARCUBE_MINERVA_FILE" ]]; then
    # The runs DB (used by match_minerva.cpp) uses the original binary filename
    # whereas ARCUBE_CHARGE_FILE is the packet file
    binaryChargeFile=$(basename $ARCUBE_CHARGE_FILE | sed 's/^packet-/binary-')
    run root -l -q "match_minerva.cpp+(\"$binaryChargeFile\", \"$tmpDir\")"
    minervaPath=$tmpDir/minerva_*.root
    if [[ ! -e "$minervaPath" ]]; then
        echo "Ay caramba! Problem in building the matched Minerva file"
        rm -rf "$tmpDir"
        exit 1
    fi
    args_gen_cafmaker_cfg+=( --minerva-path "$minervaPath" )
fi

./gen_cafmaker_cfg.data.py "${args_gen_cafmaker_cfg[@]}"

echo ===================
cat "$cfgFile"
echo ""
echo ===================

run makeCAF "--fcl=$cfgFile"

cafOutDir=$outDir
# HACK
flatCafOutDir=$(echo $cafOutDir | sed 's!/caf/!/caf.flat/!')
mkdir -p "$cafOutDir" "$flatCafOutDir"
mv "$outFile" "$cafOutDir"
mv "$flatOutFile" "$flatCafOutDir"

rm -rf "$tmpDir"
