#!/usr/bin/env bash

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh


# The setup scripts return nonzero for whatever reason
set +o errexit
source static/setup_minerva.sh
set -o errexit

inDir=${ARCUBE_OUTDIR_BASE}/run-edep2flat/output/$ARCUBE_IN_NAME
inName=$ARCUBE_IN_NAME.$globalIdx
inFile=$(realpath $inDir/FLAT/${inName}.EDEPSIM_SPILLS.FLAT.root)


rootCode='
auto t = (TTree*) _file0->Get("Event");
std::cout << t->GetEntries() << std::endl;'
nEvents=$(echo "$rootCode" | root -l -b "$inFile" | tail -1)
echo $nEvents


outFile_dst=$tmpOutDir/${outName}.dst.root
outFile_gaudiroot=$tmpOutDir/${outName}.IDODDigits.root
outFile_gaudihisto=$tmpOutDir/${outName}.Histogam.root

tmpDir=$(mktemp -d)
optionFile=$(realpath $tmpDir/${outName}.opts)

echo "TEST:"
echo $nEvents
echo $inFile
echo $outFile_gaudiroot
echo $outFile_gaudihisto
echo $outFile_dst
echo "END TEST"

cp static/sim_minerva_2x2.opts $optionFile

sed -i "s/MAXEVT/${nEvents}/g" $optionFile

sed -i "s#inputFile#${inFile}#g" $optionFile
sed -i "s#gaudiFile#${outFile_gaudiroot}#g" $optionFile
sed -i "s#histoFile#${outFile_gaudihisto}#g" $optionFile
sed -i "s#dstFile#${outFile_dst}#g" $optionFile


run SystemTestsApp.exe $optionFile
rm $optionFile
rmdir $tmpDir



dstOutDir=$outDir/DST
gaudiOutDir=$outDir/GAUDI


mkdir -p $dstOutDir
mkdir -p $gaudiOutDir

mv "$outFile_dst" "$dstOutDir"
mv "$outFile_gaudiroot" "$outFile_gaudihisto" "$gaudiOutDir"
