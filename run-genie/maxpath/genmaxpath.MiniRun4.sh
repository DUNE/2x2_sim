#!/usr/bin/env bash

# run me from run-edep-sim

export ARCUBE_CONTAINER=mjkramer/sim2x2:genie_edep.3_04_00.20230606
tune=AR23_20i_00_000
basegeom=geometry/Merged2x2MINERvA_v3/Merged2x2MINERvA_v3

./GENIE_max_path_length_gen.sh ${basegeom}_withRock.gdml $tune
./GENIE_max_path_length_gen.sh ${basegeom}_noRock.gdml $tune
./GENIE_max_path_length_gen.sh ${basegeom}_justRock.gdml $tune
