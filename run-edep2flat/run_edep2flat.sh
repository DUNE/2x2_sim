#!/usr/bin/env bash
source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh


#Configuration file to use
config_file="static/param.txt"

echo "a"
echo $SHIFTER_IMAGEREQUEST
source /cvmfs/dune.opensciencegrid.org/products/dune/setup_dune.sh
echo "b"
setup dunesw v09_45_00_00 -q e20:prof
echo "c"
setup edepsim v3_2_0 -q e20:prof
echo "b"


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
#inDir=${ARCUBE_OUTDIR_BASE}/run-spill-build/output/$ARCUBE_IN_NAME
tmp_dir="/pscratch/sd/m/mkramer/out.MiniRun5"
inDir=${tmp_dir}/run-spill-build/output/$ARCUBE_IN_NAME/EDEPSIM_SPILLS
inName=$ARCUBE_IN_NAME.$globalIdx
inFile=${inName}.EDEPSIM_SPILLS.root





flatOutDir=$outDir/FLAT
mkdir -p $flatOutDir


echo $inFile
echo $flatOutDir

outFile=${outName}.EDEPSIM_SPILLS.FLAT.root
echo $outFile
echo " " 
echo $(ls convert_edepsim_flatroot.py)
run python3 convert_edepsim_flatroot.py --offset_x "$OFFSETX" \
    --offset_y $OFFSETY \
    --offset_z $OFFSETZ \
    --input_dir "$inDir" \
    --input_file "$inFile" \
    --output_dir "$flatOutDir" \
    --output_file "$outFile" \
    --run_number $globalIdx

