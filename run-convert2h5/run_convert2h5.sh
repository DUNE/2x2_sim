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
    inFile=$ARCUBE_OUTDIR_BASE/run-spill-build/${ARCUBE_SPILL_NAME}/EDEPSIM_SPILLS/$subDir/${inName}.EDEPSIM_SPILLS.root
else
    inName=$ARCUBE_SINGLE_NAME.$globalIdx
    inFile=$ARCUBE_OUTDIR_BASE/run-edep-sim/${ARCUBE_SINGLE_NAME}/EDEPSIM/$subDir/${inName}.EDEPSIM.root
fi

outFile=$tmpOutDir/${outName}.EDEPSIM.hdf5

if [[ "$ARCUBE_KEEP_ALL_DETS" == "1" ]]; then
    keepAllDets=--keep_all_dets
else
    keepAllDets=""
fi

# After going from ROOT 6.14.06 to 6.28.06, apparently we need to point CPATH to
# the edepsim-io headers. Otherwise convert2h5 fails. (This "should" be set in
# the container already.)
export CPATH=$EDEPSIM/include/EDepSim:$CPATH

run ./convert_edepsim_roottoh5.py --input_file "$inFile" --output_file "$outFile" "$keepAllDets"

h5OutDir=$outDir/EDEPSIM_H5/$subDir
mkdir -p "$h5OutDir"
mv "$outFile" "$h5OutDir"
