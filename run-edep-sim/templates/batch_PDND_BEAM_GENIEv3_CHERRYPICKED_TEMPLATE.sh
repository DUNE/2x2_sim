#!/usr/bin/env bash

#!/bin/bash
#SBATCH --image=docker:wilkinsonnu/nuisance_project:2x2_sim_prod
#SBATCH --qos=shared
#SBATCH --constraint=haswell
#SBATCH --time=1200
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=3GB

## These change for each job
THIS_SEED=__THIS_SEED__
THIS_GEOM=__THIS_GEOM__
OUTDIR_ROOT=__OUTDIR_ROOT__
DK2NU_DIR=__DK2NU_DIR__
DK2NUFILE=__DK2NUFILE__
OUTFILE=__OUTFILE__
EXP=__EXP__

## Fixed
INPUTS_DIR=__INPUTS_DIR__
THIS_EDEP_MAC=2x2_beam_cherry.mac
TUNE=G18_10a_02_11a
DET_LOCATION="ProtoDUNE-ND"

## To calculate from inputs
MAXPATH_FILE=${GEOM_FILE/.gdml/_maxpath.xml}

## Where to do stuff
tempDir=${SCRATCH}/${OUTFILE/.root/}_${THIS_SEED}
timeFile=${OUTFILE/.root/.time}
echo "Moving to SCRATCH: ${tempDir}"
mkdir ${tempDir}
cd ${tempDir}

## Get the inputs (all in the folder CURRENTLY)
cp ${INPUTS_DIR}/* .
cp ${DK2NU_DIR}/${DK2NUFILE} .

/usr/bin/time --append -f'%E' -o ${timeFile} \
	      shifter -V ${PWD}:/output --entrypoint /bin/sh -c "export GXMLPATH=${tempDir}; gevgen_fnal \
	-e ${EXP} \
	-f ${DK2NUFILE},${DET_LOCATION} \
	-g ${THIS_GEOM} \
	-m ${MAXPATH_FILE} \
	-L cm -D g_cm3 \
	--cross-sections ${TUNE}_FNALsmall.xml \
	--tune ${TUNE} \
	--seed ${THIS_SEED}"

## Convert to rootracker
/usr/bin/time --append -f'%E' -o ${timeFile} \
	      shifter -V ${PWD}:/output --entrypoint gntpc \
	-i gntp.0.ghep.root -f rootracker -o gntp.0.roo.root

## Now cherrypick events
/usr/bin/time --append -f'%E' -o ${timeFile} \
              shifter -V ${PWD}:/output --entrypoint python3 cherrypicker.py -i gntp.0.roo.root -o gntp.0.roo.cherry.root

## Get the number of events for edepsim
NEVENTS=$(echo "TTree* tree = (TTree*)_file0->Get(\"gRooTracker\"); std::cout << tree->GetEntries() << std::endl;" | \
              shifter -V ${PWD}:/output --entrypoint root -l -b gntp.0.roo.cherry.root | tail -1)
echo "Processed ${NEVENTS}, now convert..."


## Copy back the GENIE output file
if [ ! -d "${OUTDIR_ROOT}/GENIE" ]; then
    mkdir -p ${OUTDIR_ROOT}/GENIE
fi
cp ${tempDir}/gntp.0.roo.root ${OUTDIR_ROOT}/GENIE/${OUTFILE/.root/_GENIE.root}
cp ${tempDir}/gntp.0.roo.cherry.root ${OUTDIR_ROOT}/GENIE/${OUTFILE/.root/_GENIE_CHERRYPICKED.root}

## Run edep-sim
/usr/bin/time --append -f'%E' -o ${timeFile} \
	      shifter -V ${PWD}:/output --entrypoint edep-sim \
	-C -g ${THIS_GEOM} \
	-o ${OUTFILE/.root/_EDEPSIM.root} \
	${THIS_EDEP_MAC} \
	-e ${NEVENTS}

## Copy back the edep-sim file
if [ ! -d "${OUTDIR_ROOT}/EDEPSIM" ]; then
    mkdir -p ${OUTDIR_ROOT}/EDEPSIM
fi
cp ${tempDir}/${OUTFILE/.root/_EDEPSIM.root} ${OUTDIR_ROOT}/EDEPSIM/.

## Convert to h5
/usr/bin/time --append -f'%E' -o ${timeFile} \
	      shifter -V ${PWD}:/output --entrypoint python3 dumpTree.py ${OUTFILE/.root/_EDEPSIM.root} ${OUTFILE/.root/_EDEPSIM.h5}
if [ ! -d "${OUTDIR_ROOT}/EDEPSIM_H5" ]; then
    mkdir -p ${OUTDIR_ROOT}/EDEPSIM_H5
fi
cp ${tempDir}/${OUTFILE/.root/_EDEPSIM.h5} ${OUTDIR_ROOT}/EDEPSIM_H5/.

## Now copy the timing file back
if [ ! -d "${OUTDIR_ROOT}/TIMING" ]; then
    mkdir -p ${OUTDIR_ROOT}/TIMING
fi
cp ${tempDir}/${timeFile} ${OUTDIR_ROOT}/TIMING/.

## Clean up
rm -r ${tempDir}
