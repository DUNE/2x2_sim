#!/bin/bash

THIS_SEED=0
NPOINTS=1000
NRAYS=1000

GEOM_PATH=$1; shift

MAXPATH_PATH=maxpath/$(basename $GEOM_PATH .gdml)_maxpath.xml

gmxpl \
	-f ${GEOM_PATH} \
	-L cm -D g_cm3 \
	-o ${MAXPATH_PATH} \
	-n ${NPOINTS} \
	-r ${NRAYS} \
	--seed ${THIS_SEED}
