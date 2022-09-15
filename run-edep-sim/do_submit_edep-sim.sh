#!/usr/bin/env bash

## Get all the flux file names
FILES=(${DK2NU_DIR}/*.dk2nu)
NFILES=${#FILES[@]}

echo "Generating events using ${NFILES} dk2nu files..."

## Loop over flux files
for N in $(seq ${FIRST_JOB} ${LAST_JOB})
do
    ## Get the relevant file number
    MODN=(expr ${N} % ${NFILES})
    DK2NUFILE=${FILES[${MODN}]##*/}
    printf -v PADJOB "%03d" ${N}

    OUTFILE="${THIS_GEOM/.gdml/}_${OUT_TYPE}_${EXP}_${PADJOB}.root"
    echo "Processing ${OUTFILE}"

    ## Copy the template
    THIS_TEMP=${TEMPLATE/_TEMPLATE/_${PADJOB}}
    cp ${TEMPLATE} ${THIS_TEMP}

    ## RANDOM SEED FOR EACH JOB
    sed -i "s/__THIS_SEED__/${RANDOM}/g" ${THIS_TEMP}
    sed -i "s/__OUTDIR_ROOT__/${OUTDIR_ROOT//\//\\/}/g" ${THIS_TEMP}
    sed -i "s/__DK2NU_DIR__/${DK2NU_DIR//\//\\/}/g" ${THIS_TEMP}
    sed -i "s/__XSEC_FILE__/${XSEC_FILE//\//\\/}/g" ${THIS_TEMP}
    sed -i "s/__THIS_GEOM__/${THIS_GEOM}/g" ${THIS_TEMP}
    sed -i "s/__DK2NUFILE__/${DK2NUFILE}/g" ${THIS_TEMP}
    sed -i "s/__OUTFILE__/${OUTFILE}/g" ${THIS_TEMP}
    sed -i "s/__EXP__/${EXP}/g" ${THIS_TEMP}

    echo "Submitting ${THIS_TEMP}"

    ## Submit the template
    sbatch $@ ${THIS_TEMP}

    ## No need to delete, so done
    rm ${THIS_TEMP}
done
