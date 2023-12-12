#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh

# in the container, install numpy fire h5py tqdm
source convert.venv/bin/activate

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outDir=$PWD/output/$ARCUBE_OUT_NAME
[ ! -z "${ARCUBE_OUTDIR_BASE}" ] && outDir=$ARCUBE_OUTDIR_BASE/run-convert2h5/output/$ARCUBE_OUT_NAME
mkdir -p $outDir

outName=$ARCUBE_OUT_NAME.$(printf "%05d" "$globalIdx")
echo "outName is $outName"

timeFile=$outDir/TIMING/$outName.time
mkdir -p "$(dirname "$timeFile")"
timeProg=$PWD/../run-edep-sim/tmp_bin/time      # container is missing /usr/bin/time

run() {
    echo RUNNING "$@"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@"
}

if [[ -n "$ARCUBE_SPILL_NAME" ]]; then
    inName=$ARCUBE_SPILL_NAME.$(printf "%05d" "$globalIdx")
    inFile=$PWD/../run-spill-build/output/${ARCUBE_SPILL_NAME}/EDEPSIM_SPILLS/${inName}.EDEPSIM_SPILLS.root
    [ ! -z "${ARCUBE_OUTDIR_BASE}" ] && inFile=$ARCUBE_OUTDIR_BASE/run-spill-build/output/${ARCUBE_SPILL_NAME}/EDEPSIM_SPILLS/${inName}.EDEPSIM_SPILLS.root
else
    inName=$ARCUBE_SINGLE_NAME.$(printf "%05d" "$globalIdx")
    inFile=$PWD/../run-edep-sim/output/${ARCUBE_SINGLE_NAME}/EDEPSIM/${inName}.EDEPSIM.root
    [ ! -z "${ARCUBE_OUTDIR_BASE}" ] && inFile=$ARCUBE_OUTDIR_BASE/run-edep-sim/output/${ARCUBE_SINGLE_NAME}/EDEPSIM/${inName}.EDEPSIM.root
fi

h5OutDir=$outDir/EDEPSIM_H5
mkdir -p $h5OutDir

outFile=$h5OutDir/${outName}.EDEPSIM.hdf5
rm -f $outFile

if [[ "$ARCUBE_KEEP_ALL_DETS" == "1" ]]; then
    keepAllDets=--keep_all_dets
else
    keepAllDets=""
fi

run ./convert_edepsim_roottoh5.py --input_file $inFile --output_file $outFile $keepAllDets
