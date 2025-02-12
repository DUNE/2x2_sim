#!/bin/bash

#SBATCH --account=dune
#SBATCH --qos=shared
#SBATCH --nodes=1
#SBATCH --constraint=cpu
#SBATCH --time=0:10:00
#SBATCH --mem=8GB

#shifter --image=mjkramer/sim2x2:genie_edep.3_04_00.20230912 -- /bin/bash --init-file /environment
#wait

ARCUBE_CONTAINER=mjkramer/sim2x2:ndlar011

source ../util/reload_in_container.inc.sh
source ../util/init.inc.sh

ARCUBE_GEOM_EDEP=geometry/Merged2x2MINERvA_v4/Merged2x2MINERvA_v4_noRock.gdml

nEvents=1

export ARCUBE_OUT_NAME=50MeV_10N_nothresh.edep.nu

echo ${outName}

edepRootFile=$tmpOutDir/${outName}

echo ${edepRootFile}

#edepRootFile=$tmpOutDir/*.root
#rm -f "$edepRootFile"

#edepCode="/generator/kinematics/rooTracker/input $genieFile/edep/runId $runNo"

# The geometry file is given relative to the root of 2x2_sim
export ARCUBE_GEOM_EDEP=$baseDir/${ARCUBE_GEOM_EDEP:-$ARCUBE_GEOM}

ARCUBE_EDEP_MAC=macros/2x2_beam.mac #MY MACRO
ARCUBE_RUN_OFFSET=0

# Run edep-sim
for i in $(seq 1 3);
do
    ARCUBE_CONTAINER=mjkramer/sim2x2:ndlar011
    run edep-sim -C -g "$ARCUBE_GEOM_EDEP" -o "$ARCUBE_OUT_NAME""$edepRootFile"$i".EDEPSIM.root" -u -e "$nEvents" "$ARCUBE_EDEP_MAC" > /global/cfs/cdirs/dune/users/edgarmao/NeutronSim/MonoEnergetic/$i.log
done

wait

echo $ARCUBE_OUT_NAME

mkdir -p "/global/cfs/cdirs/dune/users/edgarmao/NeutronSim/MonoEnergetic/trialrun/$ARCUBE_OUT_NAME"
mv "$edepRootFile" "/global/cfs/cdirs/dune/users/edgarmao/NeutronSim/MonoEnergetic/trialrun/$ARCUBE_OUT_NAME"