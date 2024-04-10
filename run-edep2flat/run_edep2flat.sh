#!/usr/bin/env bash
source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh


#Configuration file to use
config_file="static/param.txt"

echo $SHIFTER_IMAGEREQUEST

# The setup scripts return nonzero for whatever reason
set +o errexit
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
setup dunesw v09_45_00_00 -q e20:prof
setup edepsim v3_2_0 -q e20:prof
set -o errexit


#SETING UP THE CAMPAIGN PARAMETERS

OFFSETX=0
OFFSETY=0
OFFSETZ=0

if [[ -f "$config_file" ]]; then
  source "$config_file"
else
  echo "Warning: Configuration file not found."
fi


#Temporary hack to run locally
#tmp_dir="/pscratch/sd/m/mkramer/out.MiniRun5"
#inDir=${tmp_dir}/run-spill-build/$ARCUBE_IN_NAME/EDEPSIM_SPILLS

inDir=${ARCUBE_OUTDIR_BASE}/run-spill-build/$ARCUBE_IN_NAME/EDEPSIM_SPILLS/$subDir
inName=$ARCUBE_IN_NAME.$globalIdx
inFile=${inName}.EDEPSIM_SPILLS.root

echo $inFile

outFile=${outName}.EDEPSIM_SPILLS.FLAT.root
echo $outFile
echo " " 
echo $(ls convert_edepsim_flatroot.py)
run python3 convert_edepsim_flatroot.py --offset_x "$OFFSETX" \
    --offset_y $OFFSETY \
    --offset_z $OFFSETZ \
    --input_dir "$inDir" \
    --input_file "$inFile" \
    --output_dir "$tmpOutDir" \
    --output_file "$outFile" \
    --run_number $globalIdx


flatOutDir=$outDir/FLAT/$subDir
mkdir -p $flatOutDir
echo $flatOutDir
mv "$tmpOutDir/$outFile" "$flatOutDir"
