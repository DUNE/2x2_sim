#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh


# If we're using a container, it's responsible for the Python libraries. With no
# container, use a venv.
if [[ "$ARCUBE_RUNTIME" == "NONE" ]]; then
    source convert.venv/bin/activate
fi

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

if [[ -n "$ARCUBE_SPILL_NAME" ]]; then
    inName=$ARCUBE_SPILL_NAME.$globalIdx
    inFile=$ARCUBE_OUTDIR_BASE/run-spill-build/output/${ARCUBE_SPILL_NAME}/EDEPSIM_SPILLS/${inName}.EDEPSIM_SPILLS.root
else
    inName=$ARCUBE_SINGLE_NAME.$globalIdx
    inFile=$ARCUBE_OUTDIR_BASE/run-edep-sim/output/${ARCUBE_SINGLE_NAME}/EDEPSIM/${inName}.EDEPSIM.root
fi

h5OutDir=$outDir/EDEPSIM_H5
mkdir -p "$h5OutDir"

outFile=$h5OutDir/${outName}.EDEPSIM.hdf5
rm -f "$outFile"

if [[ "$ARCUBE_KEEP_ALL_DETS" == "1" ]]; then
    keepAllDets=--keep_all_dets
else
    keepAllDets=""
fi

run ./convert_edepsim_roottoh5.py --input_file "$inFile" --output_file "$outFile" "$keepAllDets"
