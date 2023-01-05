#!/usr/bin/env bash

source /environment
source muongun_vars.inc.sh

cd ../run-edep-sim

./GENIE_max_path_length_gen.sh $(realpath $ARCUBE_GEOM) $ARCUBE_TUNE
