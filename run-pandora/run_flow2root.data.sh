#!/usr/bin/env bash

export ARCUBE_DIR=${ARCUBE_DIR:-$(realpath "$PWD"/..)}
export ARCUBE_CONTAINER=${ARCUBE_CONTAINER:-fermilab/fnal-wn-sl7:latest}

# Container
source $ARCUBE_DIR/util/reload_in_container.inc.sh

# Setup Pandora environment
source $ARCUBE_DIR/run-pandora/setup_pandora.sh

# Set other environment variables: globalIdx, ARCUBE_OUTDIR_BASE, tmpOutDir, outDir, outName, subDir
source $ARCUBE_DIR/util/init.data.inc.sh

# Prevent excessive memory use
export OMP_NUM_THREADS=1

outName=$(basename "$ARCUBE_CHARGE_FILE" .h5).FLOW.hdf5_hits.root
outFile=${tmpOutDir}/${outName}

inName=$(basename "$ARCUBE_CHARGE_FILE" .h5).FLOW.hdf5
inFile=${ARCUBE_FLOW_DIR_BASE}/${relDir}/${inName}

rm -f "$outFile"

isData=1
isFinal=${ARCUBE_USE_FINAL_HITS:-1}

source $ARCUBE_PANDORA_INSTALL/pandora.venv/bin/activate
run python3 $ARCUBE_PANDORA_INSTALL/LArRecoND/ndlarflow/h5_to_root_ndlarflow.py $inFile $isData $isFinal ${outFile}.firstStep.root
run root -l -q $ARCUBE_PANDORA_INSTALL/LArRecoND/ndlarflow/rootToRootConversion.C+\(true,\"${outFile}.firstStep.root\",\"${outFile}\"\)
rm ${outFile}.firstStep.root
deactivate

mv "${outFile}" "${outDir}"

echo "Written to $(realpath "${outDir}/$(basename "$outFile")")"
