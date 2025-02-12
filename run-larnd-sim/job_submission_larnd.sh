#!/bin/bash

#SBATCH --nodes=1
#SBATCH --account=dune
#SBATCH --qos=regular
#SBATCH --time=0:20:00
#SBATCH --mem=8GB

#shifter --image=mjkramer/sim2x2:genie_edep.3_04_00.20230912 -- /bin/bash --init-file /environment
#wait

outFile=large_n_custom.hdf5

mkdir ${SCRATCH}/$1/larndsim_run

cd ${SCRATCH}/$1/larndsim_run

cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/input/10N.convert2h5.0000000.EDEPSIM.hdf5 .
cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/larndsim/detector_properties/2x2.yaml .
cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/larndsim/pixel_layouts/multi_tile_layout-3.0.40.yaml .
cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/larndsim/bin/light_noise_2x2_4mod_July2023.npy .
cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/larndsim/bin/response_44.npy .
cp /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/larndsim/simulation_properties/2x2_NuMI_sim.yaml .
cp /global/cfs/cdirs/dune/www/data/2x2/simulation/larndsim_data/light_LUT_M123_v1/lightLUT_M123.npz .

module load cudatoolkit/11.7
module load python

source /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd.venv/bin/activate

python3 /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/larnd-sim/cli/simulate_pixels.py --input_filename 10N.convert2h5.0000000.EDEPSIM.hdf5 \
        --output_filename $outFile \
        --detector_properties 2x2.yaml \
        --pixel_layout multi_tile_layout-3.0.40.yaml \
        --light_lut_filename lightLUT_M123.npz \
        --light_det_noise_filename light_noise_2x2_4mod_July2023.npy \
        --response_file response_44.npy \
        --simulation_properties 2x2_NuMI_sim.yaml $1 &
wait

cp /pscratch/sd/e/edgarmao/larndsim_run/$outFile /global/homes/e/edgarmao/2x2_sim/run-larnd-sim/output/
rm -rf ${SCRATCH}/$1/larndsim_run

module unload python
module unload cudatoolkit/11.7

cd ~/2x2_sim/run-larnd-sim