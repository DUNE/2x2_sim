#!/usr/bin/env bash

export ARCUBE_RUNTIME=SHIFTER
export ARCUBE_CONTAINER=mjkramer/sim2x2:mlreco001

source ../util/reload_in_container.inc.sh

cd install/dune-nd-lar-reco

mkdir -p $SCRATCH/mlreco

# SINGLES_WGTS=/wclustre/dune/jwolcott/dune/nd/nd-lar-reco/train/track+showergnn-380Kevs-15Kits-batch32/snapshot-1499.ckpt
# SINGLES_INPUT=/wclustre/dune/jwolcott/dune/nd/nd-lar-reco/supera/singles/neutrino.0.larcv.root
SINGLES_WGTS=/dvs_ro/cfs/cdirs/dune/users/mkramer/mywork/mlreco/weights/snapshot-1499.ckpt
SINGLES_INPUT=/dvs_ro/cfs/cdirs/dune/users/mkramer/mywork/mlreco/inputs/neutrino.0.larcv.root

python3 RunChain.py \
    --config_file configs/config.inference.fullchain-singles.yaml \
    --model_file $SINGLES_WGTS \
    --batch_size 1 \
    -n 5 \
    --input_file $SINGLES_INPUT \
    --output_file $SCRATCH/mlreco/neutrino.0.larcv.5events.npz

# PILEUP_WGTS=/wclustre/dune/jwolcott/dune/nd/nd-lar-reco/train/track+intergnn-1400evs-1000Kits-batch8/snapshot-49.ckpt
# PILEUP_INPUT=/wclustre/dune/jwolcott/dune/nd/nd-lar-reco/supera/1.2MW/FHC.1000001.larcv.root
PILEUP_WGTS=/dvs_ro/cfs/cdirs/dune/users/mkramer/mywork/mlreco/weights/snapshot-49.ckpt
PILEUP_INPUT=/dvs_ro/cfs/cdirs/dune/users/mkramer/mywork/mlreco/inputs/FHC.1000001.larcv.root

python3 RunChain.py \
    --config_file configs/config.inference.fullchain-pileup.yaml \
    --model_file $PILEUP_WGTS \
    --batch_size 1 \
    --input_file $PILEUP_INPUT \
    --output_file $SCRATCH/mlreco/FHC.1000001.larcv.5events.npz
