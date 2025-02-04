#!/usr/bin/env bash
set -o errexit

# Using initialization from general 2x2 sim workflow to get pre-defined variable
# definitions
#source ../util/reload_in_container.inc.sh (but we don't really need this one)
source ../util/init.inc.sh

# Use local NERSC Python library
module load python 

# Set values for inputs specific to simple "edepsim" event generation
export EVENTS_PER_FILE=100
export ARCUBE_OUT_NAME='test_fake_edepsim'

outName=$ARCUBE_OUT_NAME.$globalIdx
outFile=$tmpOutDir/${outName}.hdf5

# Run script to generate simple events
python make_simple_events_h5.py -n $EVENTS_PER_FILE -o $outFile


# Move output file to appropriate directory
h5OutDir=$outDir/TEST_FAKE_EDEPSIM_H5/$subDir
mkdir -p "$h5OutDir"
mv "$outFile" "$h5OutDir"