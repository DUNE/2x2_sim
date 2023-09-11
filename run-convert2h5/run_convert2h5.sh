#!/usr/bin/env bash

if [[ "$ARCUBE_RUNTIME" == "SHIFTER" ]]; then
    # Reload in Shifter
    if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
        shifter --image=$ARCUBE_CONTAINER --module=none -- "$0" "$@"
        exit
    fi

elif [[ "$ARCUBE_RUNTIME" == "SINGULARITY" ]]; then
    # Or reload in Singularity
    if [[ "$SINGULARITY_NAME" != "$ARCUBE_CONTAINER" ]]; then
        singularity exec -B $ARCUBE_DIR $ARCUBE_CONTAINER_DIR/$ARCUBE_CONTAINER /bin/bash "$0" "$@"
        exit
    fi

else
    echo "Unsupported \$ARCUBE_RUNTIME"
    exit
fi

# source /environment             # provided by the container
source $ARCUBE_DIR/admin/container_env.sh

# in the container, install numpy fire h5py tqdm
source convert.venv/bin/activate

if [[ "$NERSC_HOST" == "cori" ]]; then
    export HDF5_USE_FILE_LOCKING=FALSE
fi

globalIdx=$ARCUBE_INDEX
echo "globalIdx is $globalIdx"

outDir=$PWD/output/$ARCUBE_OUT_NAME
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
else
    inName=$ARCUBE_SINGLE_NAME.$(printf "%05d" "$globalIdx")
    inFile=$PWD/../run-edep-sim/output/${ARCUBE_SINGLE_NAME}/EDEPSIM/${inName}.EDEPSIM.root
fi

h5OutDir=$outDir/EDEPSIM_H5
mkdir -p $h5OutDir

outFile=$h5OutDir/${outName}.EDEPSIM.h5
rm -f $outFile

if [[ "$ARCUBE_KEEP_ALL_DETS" == "1" ]]; then
    keepAllDets=--keep_all_dets
else
    keepAllDets=""
fi

run ./convert_edepsim_roottoh5.py --input_file $inFile --output_file $outFile $keepAllDets
