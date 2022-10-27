#!/usr/bin/env bash

outName=$1; shift
outDir=../run-edep-sim/output/"$outName"
inDir=input/"$outName"

mkdir -p "$inDir"

ls $(realpath "$outDir"/EDEPSIM_H5)/*.h5 > "$inDir"/input.list
