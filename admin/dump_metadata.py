#!/usr/bin/env python3

# Data tiers: https://samweb.fnal.gov:8483/sam/dune/api/values/data_tiers
# File types: https://samweb.fnal.gov:8483/sam/dune/api/values/file_types

# export LD_LIBRARY_PATH=/global/cfs/cdirs/dayabay/scratch/mkramer/venvs/ibdsel3/lib/python3.10/site-packages/zmq/backend/cython/../../../pyzmq.libs:$LD_LIBRARY_PATH

# TODO add a create_date? doesn't seem to be required for samweb, although
# apparently created_timestamp (as well as creator) are required by metacat, per
# https://github.com/DUNE/data-mgmt-testing/blob/main/metacat/rawDataExample.md ?

import json
import os
import zlib

import h5py
import numpy as np
import ROOT as R

R.gSystem.Load('libTG4Event/libTG4Event.so')


def get_event_stats_edep(datapath: str):
    f = R.TFile(datapath)
    m = f.event_spill_map
    t = f.EDepSimEvents

    def spill_of(entry):
        t.GetEntry(entry)
        e = t.Event
        idstr = f'{e.RunId} {e.EventId}'
        return int(m.GetValue(idstr).GetString().Data())

    first = spill_of(0)
    last = spill_of(t.GetEntries() - 1)
    count = last - first + 1

    f.Close()
    return count, first, last


def get_event_stats_larnd(datapath: str):
    with h5py.File(datapath) as f:
        spills = np.unique(f['vertices']['spillID'])
        first = spills.min()
        last = spills.max()
        count = last - first + 1

        return int(count), int(first), int(last)


def get_event_stats_flow(datapath: str):
    with h5py.File(datapath) as f:
        spills = np.unique(f['/mc_truth/trajectories/data']['spillID'])
        first = spills.min()
        last = spills.max()
        count = last - first + 1

        return int(count), int(first), int(last)


# NOTE: According to
# https://github.com/DUNE/data-mgmt-testing/blob/main/metacat/rawDataExample.md
# the checksums are generated automatically by the system. Does this only apply
# to metacat, not SAM/FTS?
def get_checksum(datapath: str, chunksize=1_000_000_000):
    cksum = 1
    with open(datapath, 'rb') as f:
        while data := f.read(chunksize):
            cksum = zlib.adler32(data, cksum)
    return cksum & 0xffffffff


def dump_metadata(datapath: str):
    meta = {}

    meta['file_name'] = os.path.basename(datapath)
    meta['file_type'] = 'mc'
    meta['file_size'] = int(os.path.getsize(datapath))
    meta['checksum'] = [f'enstore:{get_checksum(datapath)}']
    meta['data_stream'] = 'physics'
    meta['application'] = ['2x2_sim', 'MiniRun3', 'MiniRun3_1E19_RHC']
    meta['group'] = 'dune'

    if datapath.endswith('.EDEPSIM_SPILLS.root'):
        meta['file_format'] = 'root'
        meta['data_tier'] = 'simulated'
        meta['event_count'], meta['first_event'], meta['last_event'] = \
            get_event_stats_edep(datapath)

    elif datapath.endswith('.LARNDSIM.h5'):
        meta['file_format'] = 'hdf5'
        meta['data_tier'] = 'detector-simulated'
        meta['event_count'], meta['first_event'], meta['last_event'] = \
            get_event_stats_larnd(datapath)
        edep_name = meta['file_name'].replace('.LARNDSIM.h5', '.EDEPSIM_SPILLS.root')
        meta['parents'] = [edep_name]

    elif datapath.endswith('.FLOW.h5'):
        meta['file_format'] = 'hdf5'
        meta['data_tier'] = 'hit-reconstructed'
        meta['event_count'], meta['first_event'], meta['last_event'] = \
            get_event_stats_flow(datapath)
        edep_name = meta['file_name'].replace('.FLOW.h5', '.EDEPSIM_SPILLS.root')
        larnd_name = meta['file_name'].replace('.FLOW.h5', '.LARNDSIM.h5')
        meta['parents'] = [larnd_name, edep_name]

    print(f'Dumping to {datapath+".json"}')
    with open(datapath + '.json', 'w') as f:
        json.dump(meta, f, indent=4)


def test():
    path_edep = '/global/cfs/cdirs/dune/www/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.spill/EDEPSIM_SPILLS/MiniRun3_1E19_RHC.spill.00001.EDEPSIM_SPILLS.root'
    path_larnd = '/global/cfs/cdirs/dune/www/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.larnd/LARNDSIM/MiniRun3_1E19_RHC.larnd.00001.LARNDSIM.h5'
    path_flow = '/global/cfs/cdirs/dune/www/data/2x2/simulation/productions/MiniRun3_1E19_RHC/MiniRun3_1E19_RHC.flow/FLOW/MiniRun3_1E19_RHC.flow.00001.FLOW.h5'

    dump_metadata(path_edep)
    dump_metadata(path_larnd)
    dump_metadata(path_flow)


if __name__ == '__main__':
    test()
