#!/usr/bin/env bash

./dump_metadata.py --all ../run-spill-build/output/MiniRun3_1E19_RHC.spill/EDEPSIM_SPILLS --app run-spill-build --campaign MiniRun3_1E19_RHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current -200 --event-id-var eventID
./dump_metadata.py --all ../run-larnd-sim/output/MiniRun3_1E19_RHC.larnd_v2/LARNDSIM --app run-larnd-sim --campaign MiniRun3_1E19_RHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current -200 --event-id-var eventID
./dump_metadata.py --all ../run-ndlar-flow/output/MiniRun3_1E19_RHC.flow_v6/FLOW --app run-ndlar-flow --campaign MiniRun3_1E19_RHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current -200 --event-id-var eventID --parents MiniRun3_1E19_RHC.larnd_v2

./dump_metadata.py --all ../run-spill-build/output/MiniRun4_1E19_RHC.spill/EDEPSIM_SPILLS --app run-spill-build --campaign MiniRun4_1E19_RHC --geom Merged2x2MINERvA_v3 --top-vol volWorld --horn-current -200
./dump_metadata.py --all ../run-larnd-sim/output/MiniRun4_1E19_RHC.larnd/LARNDSIM --app run-larnd-sim --campaign MiniRun4_1E19_RHC --geom Merged2x2MINERvA_v3 --top-vol volWorld --horn-current -200
./dump_metadata.py --all ../run-ndlar-flow/output/MiniRun4_1E19_RHC.flow/FLOW --app run-ndlar-flow --campaign MiniRun4_1E19_RHC --geom Merged2x2MINERvA_v3 --top-vol volWorld --horn-current -200

./dump_metadata.py --all ../run-spill-build/output/MicroRun3.1_1E18_FHC.spill/EDEPSIM_SPILLS --app run-spill-build --campaign MicroRun3.1_1E18_FHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current 200 --event-id-var eventID
./dump_metadata.py --all ../run-larnd-sim/output/MicroRun3.1_1E18_FHC.larnd/LARNDSIM --app run-larnd-sim --campaign MicroRun3.1_1E18_FHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current 200 --event-id-var eventID
./dump_metadata.py --all ../run-ndlar-flow/output/MicroRun3.1_1E18_FHC.flow/FLOW --app run-ndlar-flow --campaign MicroRun3.1_1E18_FHC --geom Merged2x2MINERvA_v2 --top-vol world_vol --horn-current 200 --event-id-var eventID
