#!/usr/bin/env bash

ARCUBE_OUTDIR_BASE="/pscratch/sd/a/abooth/MiniProdN1p1-v1r1"
CAMPAIGN="MiniProdN1p1_NDLAr_1E19_RHC"
GEOMETRY="nd_hall_with_lar_tms_sand"
HORN="rhc"
TOPVOL="volArgonCubeDetector75+rockbox"

#./dump_metadata.py --all ${ARCUBE_OUTDIR_BASE}/ --app run-spill-build --campaign ${CAMPAIGN} --geom ${GEOMETRY} --top-vol ${TOPVOL} --horn-current ${HORN}
./dump_metadata.py --one /pscratch/sd/a/abooth/MiniProdN1p1-v1r1/run-spill-build/output/MiniProdN1p1_NDLAr_1E19_RHC.spill/EDEPSIM_SPILLS/MiniProdN1p1_NDLAr_1E19_RHC.spill.00315.EDEPSIM_SPILLS.root --app run-spill-build --campaign ${CAMPAIGN} --geom ${GEOMETRY} --top-vol ${TOPVOL} --horn-current ${HORN}

