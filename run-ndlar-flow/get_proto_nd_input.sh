#!/bin/bash

#DATA_DIR=$1
DATA_DIR="ndlar_flow/data/proto_nd_flow/"

HERE=`pwd`

cd ${DATA_DIR}

# tile layout describing a *single* module (fix me)
curl -O https://portal.nersc.gov/project/dune/data/2x2/simulation/kwood_dev/proto_nd_flow_inputs/multi_tile_layout-2.3.16.yaml 

mv multi_tile_layout-2.3.16.yaml ${DATA_DIR}

# 2x2 detector description
curl -O https://portal.nersc.gov/project/dune/data/2x2/simulation/kwood_dev/proto_nd_flow_inputs/2x2.yaml

mv 2x2.yaml ${DATA_DIR}

# place holder for run list
curl -O https://portal.nersc.gov/project/dune/data/2x2/simulation/kwood_dev/proto_nd_flow_inputs/runlist-2x2-mcexample.txt

mv runlist-2x2-mvexample.txt ${DATA_DIR}

# place holder for light system geometry description
curl -O https://portal.nersc.gov/project/dune/data/2x2/simulation/kwood_dev/proto_nd_flow_inputs/light_module_desc-0.0.0.yaml

mv light_module_desc-0.0.0.yaml ${DATA_DIR}


cd ${HERE}
