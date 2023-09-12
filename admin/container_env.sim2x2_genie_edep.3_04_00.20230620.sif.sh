#!/bin/sh
# Custom environment shell code should follow


    export SINGULARITY_SHELL=/bin/bash
    export GEN_DIR=/opt/generators
    export ROOTSYS=${GEN_DIR}/root/install
    cd ${ROOTSYS}/bin; source thisroot.sh; cd -



    source scl_source enable devtoolset-7

    export GEN_DIR=/opt/generators
    export GENIE=${GEN_DIR}/GENIE/R-3_04_00
    export LHAPATH=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/include/LHAPDF
    export PYTHIA6=${GEN_DIR}/root/lib
    export GSL_LIB=/usr/lib64
    export GSL_INC=/usr/include
    export LHAPDF_INC=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/include
    export LHAPDF_LIB=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/lib
    export LIBXML2_INC=/usr/include/libxml2
    export LIBXML2_LIB=/usr/lib64

    export PATH=$GENIE/bin:$PATH
    export LD_LIBRARY_PATH=$LIBXML2_LIB:$LHAPDF_LIB:$PYTHIA6:$GENIE/lib:$LD_LIBRARY_PATH

    export GXMLPATH=${GENIE}/genie_xsec
    export DK2NU=${GEN_DIR}/dk2nu
    export LD_LIBRARY_PATH=${DK2NU}/lib:${LD_LIBRARY_PATH}

    ## Use G4's script because it sets so many variables
    cd ${GEN_DIR}/geant4/install/bin; source geant4.sh; cd -

    export EDEPSIM=${GEN_DIR}/edep-sim/install
    export PATH=${EDEPSIM}/bin:${PATH}
    export LD_LIBRARY_PATH=${EDEPSIM}/lib:${LD_LIBRARY_PATH}



    source scl_source enable devtoolset-7

    export GEN_DIR=/opt/generators
    export GENIE=${GEN_DIR}/GENIE/R-3_04_00
    export LHAPATH=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/include/LHAPDF
    export PYTHIA6=${GEN_DIR}/root/lib
    export GSL_LIB=/usr/lib64
    export GSL_INC=/usr/include
    export LHAPDF_INC=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/include
    export LHAPDF_LIB=${GEN_DIR}/LHAPDF/lhapdf-5.9.1_build/lib
    export LIBXML2_INC=/usr/include/libxml2
    export LIBXML2_LIB=/usr/lib64

    export PATH=$GENIE/bin:$PATH
    export LD_LIBRARY_PATH=$LIBXML2_LIB:$LHAPDF_LIB:$PYTHIA6:$GENIE/lib:$LD_LIBRARY_PATH

    export GXMLPATH=${GENIE}/genie_xsec
    export DK2NU=${GEN_DIR}/dk2nu
    export LD_LIBRARY_PATH=${DK2NU}/lib:${LD_LIBRARY_PATH}

    ## Use G4's script because it sets so many variables
    cd ${GEN_DIR}/geant4/install/bin; source geant4.sh; cd -

    export EDEPSIM=${GEN_DIR}/edep-sim/install
    export PATH=${EDEPSIM}/bin:${PATH}
    export LD_LIBRARY_PATH=${EDEPSIM}/lib:${LD_LIBRARY_PATH}

