#!/usr/bin/env bash

# TEMPLATE=$PWD/templates/batch_PDND_BEAM_GENIEv3_CHERRYPICKED_TEMPLATE.sh
THIS_SEED=12345
THIS_GEOM=$PWD/geometry/Merged2x2MINERvA_noRock.gdml
MAXPATH_FILE=$PWD/maxpath/Merged2x2MINERvA_noRock_maxpath.xml
OUT_TYPE=NuMI_RHC_CHERRY
OUTDIR_ROOT=$PWD/output/${OUT_TYPE}
DK2NU_DIR=/global/cfs/cdirs/dune/users/2x2EventGeneration/NuMI_dk2nu/newtarget-200kA_20220409
DK2NUFILE=$(find $DK2NU_DIR -name '*.dk2nu' | head -1)
XSEC_FILE=/global/cfs/cdirs/dune/users/2x2EventGeneration/inputs/NuMI/G18_10a_02_11a_FNALsmall.xml
EXP=5E17
THIS_EDEP_MAC=$PWD/macros/2x2_beam_cherry.mac
TUNE=G18_10a_02_11a
DET_LOCATION="ProtoDUNE-ND"

mkdir -p $OUTDIR_ROOT

timeFile=timing.txt

run() {
    # Copied /usr/bin/time since it isn't available in the container
    # Should add "shifter" when this is in a job script
    ./time --append -f "$1 %P %M %E" -o $timeFile $@
}

mkdir -p $OUTDIR_ROOT/GENIE

export GXMLPATH=$PWD/flux

GENIE_OUT_PREFIX=$OUTDIR_ROOT/GENIE/$(basename $DK2NUFILE .dk2nu)

run gevgen_fnal \
    -e ${EXP} \
    -f ${DK2NUFILE},${DET_LOCATION} \
    -g ${THIS_GEOM} \
    -m ${MAXPATH_FILE} \
    -L cm -D g_cm3 \
    --cross-sections ${XSEC_FILE} \
    --tune ${TUNE} \
    --seed ${THIS_SEED} \
    -o $GENIE_OUT_PREFIX

run gntpc -i $GENIE_OUT_PREFIX.0.ghep.root -f rootracker -o $GENIE_OUT_PREFIX.0.roo.root
rm $GENIE_OUT_PREFIX.0.ghep.root

run ./cherrypicker.py -i $GENIE_OUT_PREFIX.0.roo.root -o $GENIE_OUT_PREFIX.0.roo.cherry.root

NEVENTS=$(echo "TTree* tree = (TTree*)_file0->Get(\"gRooTracker\"); std::cout << tree->GetEntries() << std::endl;" | \
    root -l -b $GENIE_OUT_PREFIX.0.roo.cherry.root | tail -1)

mkdir -p $OUTDIR_ROOT/EDEPSIM
EDEPSIMFILE=$OUTDIR_ROOT/EDEPSIM/$(basename $DK2NUFILE .dk2nu)_EDEPSIM.root

run edep-sim -C -g $THIS_GEOM -o $EDEPSIMFILE $THIS_EDEP_MAC -e $NEVENTS

mkdir -p $OUTDIR_ROOT/EDEPSIM_H5
EDEPSIMFILE_H5=$OUTDIR_ROOT/EDEPSIM_H5/$(basename $DK2NUFILE .dk2nu)_EDEPSIM.h5

run $LARND_SIM/cli/dumpTree.py $EDEPSIMFILE $EDEPSIMFILE_H5
