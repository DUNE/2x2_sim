#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/prelude.inc.sh"

# NOTE: We assume that this script is "sourced" from e.g.
# run-edep-sim/run_edep_sim.sh and that the current working directory is e.g.
# run-edep-sim. Parent dir should be root of 2x2_sim.

# Default to the root of the 2x2_sim repo (but ideally this should be set to
# somewhere on $SCRATCH)
ARCUBE_OUTDIR_BASE="${ARCUBE_OUTDIR_BASE:-$PWD/..}"
mkdir -p "$ARCUBE_OUTDIR_BASE"
ARCUBE_OUTDIR_BASE=$(realpath "$ARCUBE_OUTDIR_BASE")
export ARCUBE_OUTDIR_BASE

ARCUBE_LOGDIR_BASE="${ARCUBE_LOGDIR_BASE:-$PWD/..}"
mkdir -p "$ARCUBE_LOGDIR_BASE"
ARCUBE_LOGDIR_BASE=$(realpath "$ARCUBE_LOGDIR_BASE")
export ARCUBE_LOGDIR_BASE

# For "local" (i.e. non-container, non-CVMFS) installs of larnd-sim etc.
# Default to run-larnd-sim etc.
export ARCUBE_INSTALL_DIR=${ARCUBE_INSTALL_DIR:-$PWD}

inName=$(basename "$ARCUBE_CHARGE_FILE")
relDir=$(dirname ${ARCUBE_CHARGE_FILE#"$ARCUBE_INDIR_BASE"})

outDir=$ARCUBE_OUTDIR_BASE/$relDir
mkdir -p "$outDir"

tmpOutDir=$ARCUBE_OUTDIR_BASE/tmp/$relDir
mkdir -p "$tmpOutDir"

logBase=$ARCUBE_LOGDIR_BASE
echo "logBase is $logBase"
logDir=$logBase/LOGS/$relDir
timeDir=$logBase/TIMING/$relDir
mkdir -p "$logDir" "$timeDir"
logFile=$logDir/$inName.log
timeFile=$timeDir/$inName.time

timeProg=/usr/bin/time
# HACK in case we forget to include GNU time in a container
[[ ! -e "$timeProg" ]] && timeProg=$PWD/../tmp_bin/time

run() {
    echo RUNNING "$@" | tee -a "$logFile"
    time "$timeProg" --append -f "$1 %P %M %E" -o "$timeFile" "$@" 2>&1 | tee -a "$logFile"
}

libpath_remove() {
  LD_LIBRARY_PATH=":$LD_LIBRARY_PATH:"
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":"/"::"}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//":$1:"/}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH//"::"/":"}
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH#:}; LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}
}

# Tell the HDF5 library not to lock files, since that sometimes fails on Perlmutter
export HDF5_USE_FILE_LOCKING=FALSE
