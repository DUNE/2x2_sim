#!/bin/bash

echo "Running edep-sim, this are the variables used:"
echo "NEVENTS: ${NEVENTS}"
echo "PHYSLIST: ${PS_LIST}"
echo "SOURCE: ${TYPE}"



timestamp=$(date +%s)
source $SCRATCH/setup_2x2_container.sh 
export ARCUBE_GEOM='/pscratch/sd/l/lmlepin/2x2_sim/geometry/Merged2x2MINERvA_v4/Merged2x2MINERvA_v4_noRock.gdml'
export ARCUBE_GEOM_ROCK='/pscratch/sd/l/lmlepin/2x2_sim/geometry/Merged2x2MINERvA_v4/Merged2x2MINERvA_v4_withRock.gdml'
export OUT_FILE="$SCRATCH/grid_output/neutron_gun_2x2_${PS_LIST}_${TYPE}_${timestamp}.root"

echo "Output file: ${OUT_FILE}"

cp $SCRATCH/2x2_sim_develop/2x2_sim/run-edep-sim/macros/2x2_AmBe_grid.mac $SCRATCH/cache/2x2_AmBe_grid.mac  

export MAC_FILE="${SCRATCH}/cache/2x2_AmBe_grid.mac "

# Replace energy value 
# sed -i 's/\${energy}/'$ENERGY'/g' $MAC_FILE

echo "The following edep-sim command will be executed..."
echo "edep-sim -g ${ARCUBE_GEOM} -o ${OUT_FILE} -p ${PS_LIST} -u -e ${NEVENTS} ${MAC_FILE}"
edep-sim -g "$ARCUBE_GEOM" -o "$OUT_FILE" -p "$PS_LIST" -u -e "$NEVENTS" "$MAC_FILE"
