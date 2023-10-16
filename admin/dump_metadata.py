#!/usr/bin/env python3

# Data tiers: https://samweb.fnal.gov:8483/sam/dune/api/values/data_tiers
# File types: https://samweb.fnal.gov:8483/sam/dune/api/values/file_types
# Run types: https://samweb.fnal.gov:8483/sam/dune/api/values/run_types

import argparse
import json
from multiprocessing import Pool
import os
from pathlib import Path
import zlib

import h5py
import numpy as np
import ROOT as R

g4evtdir = os.getenv('LIBTG4EVENT_DIR', 'libTG4Event')
R.gSystem.Load(f'{g4evtdir}/libTG4Event.so')


def get_event_stats_edep(datapath: Path):
    f = R.TFile(datapath.as_posix())
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


def get_event_stats_hdf5(datapath: Path, dset_name: str, event_id_var: str):
    with h5py.File(datapath) as f:
        spills = np.unique(f[dset_name][event_id_var])
        first = spills.min()
        last = spills.max()
        count = last - first + 1

        return int(count), int(first), int(last)


# NOTE: According to
# https://github.com/DUNE/data-mgmt-testing/blob/main/metacat/rawDataExample.md
# the checksums are generated automatically by the system. Does this only apply
# to metacat, not SAM/FTS? Apparently.
def get_checksum(datapath: Path, chunksize=1_000_000_000):
    cksum = 1
    with open(datapath, 'rb') as f:
        while data := f.read(chunksize):
            cksum = zlib.adler32(data, cksum)
    return cksum & 0xffffffff


def get_ext(args: argparse.Namespace):
    match args.app:
        case 'run-spill-build' | 'run-tms-reco':
            return 'root'
        case 'run-larnd-sim' | 'run-ndlar-flow':
            return 'hdf5'


def get_runtype(args: argparse.Namespace):
    match args.app:
        case 'run-spill-build':
            return 'neardet-2x2'
        case 'run-larnd-sim' | 'run-ndlar-flow':
            return 'neardet-2x2-lar'
        # TODO: To be decided.
        # Discussed around here: https://dunescience.slack.com/archives/CKXSC8EG3/p1697488314084449
        case 'run-tms-reco':
            return 'neardet'


def get_data_tier(args: argparse.Namespace):
    match args.app:
        case 'run-spill-build':
            return 'simulated'
        case 'run-larnd-sim':
            return 'detector-simulated'
        case 'run-ndlar-flow':
            return 'hit-reconstructed'
        # TODO: This is to be decided.
        # Discussed around here: https://dunescience.slack.com/archives/CKXSC8EG3/p1697490158091829
        case 'run-tms-reco':
            return 'root-tuple'


def get_event_stats(datapath: Path, args: argparse.Namespace):
    match args.app:
        case 'run-spill-build':
            return get_event_stats_edep(datapath)
        case 'run-larnd-sim':
            return get_event_stats_hdf5(datapath, 'vertices', args.event_id_var)
        case 'run-ndlar-flow':
            return get_event_stats_hdf5(datapath, '/mc_truth/trajectories/data',
                                        args.event_id_var)
        # TODO: Decide what to do here. We could
        # write a new function which queries the 
        # TMSRECO root file. This is only beneficial
        # if the "number of tracks which deposit
        # energy in the TMS" can be obtained from
        # these files. If not, set up the logic to 
        # use the information of the parent EDEPSIM_SPILLS
        # files.
        #case 'run-tms-reco':
        #    return get_event_stats_edep(datapath)


def get_parents(datapath: Path, args: argparse.Namespace):
    parts = datapath.name.split('.')
    fileno = parts[-3]              # 00321
    basename = '.'.join(parts[:-4]) # MiniRun4_1E19_RHC

    match args.app:
        case 'run-spill-build':
            return None
        case 'run-larnd-sim' | 'run-tms-reco':
            if not (base := args.parents):
                base = f'{basename}.spill'
            return [f'{base}.{fileno}.EDEPSIM_SPILLS.root']
        case 'run-ndlar-flow':
            if not (base := args.parents):
                base = f'{basename}.larnd'
            return [f'{base}.{fileno}.LARNDSIM.hdf5']


def get_runno(datapath: Path):
    return int(datapath.name.split('.')[-3])


def dump_metadata(datapath: Path, args: argparse.Namespace):
    meta = {}

    meta['file_name'] = datapath.name
    meta['file_type'] = 'mc'
    meta['file_size'] = datapath.stat().st_size
    meta['file_format'] = get_ext(args)

    if args.sam:                # for samweb validate-metadata
        meta['checksum'] = [f'adler32:{get_checksum(datapath):08x}']
    else:                       # for declaration daemon
        meta['checksum'] = f'{get_checksum(datapath):08x}'

    meta['data_stream'] = 'physics'
    meta['group'] = 'dune'
    meta['application'] = {'family': args.family,
                           'name': args.app,
                           'version': args.campaign}

    meta['DUNE.campaign'] = args.campaign
    meta['DUNE.generators'] = 'genie'
    meta['DUNE_MC.geometry_version'] = args.geom
    meta['DUNE_MC.name'] = args.campaign
    meta['DUNE_MC.TopVolume'] = args.top_vol
    meta['LBNF_MC.HornCurrent'] = args.horn_current

    meta['data_tier'] = get_data_tier(args)
    meta['runs'] = [[get_runno(datapath), 1, get_runtype(args)]]

    meta['event_count'], meta['first_event'], meta['last_event'] = \
        get_event_stats(datapath, args)

    if parents := get_parents(datapath, args):
        meta['parents'] = parents

    jsonpath = datapath.with_suffix(datapath.suffix + '.json')
    print(f'Dumping to {jsonpath}')
    with open(jsonpath, 'w') as f:
        json.dump(meta, f, indent=4)
        f.write('\n')


def main():
    ap = argparse.ArgumentParser()
    inputs = ap.add_mutually_exclusive_group(required=True)
    inputs.add_argument('--one', type=Path, help='One file to process')
    inputs.add_argument('--all', type=Path, help='Whole directory to process')
    ap.add_argument('--app', help='Name of application', required=True,
                    choices=['run-spill-build',
                             'run-larnd-sim',
                             'run-ndlar-flow',
                             'run-tms-reco'])
    ap.add_argument('--family', help='Name of family', required=True, 
                    # TODO: Are we happy with ND_Production
                    # as the family?
                    choices=['2x2_sim',
                             'ND_Production'], default='2x2_sim')
    ap.add_argument('--campaign', help='Name of campaign', required=True)
    ap.add_argument('--geom', help='Name of geometry', required=True)
    ap.add_argument('--top-vol', help='Name of top volume', required=True)
    ap.add_argument('--horn-current', help='Horn current in kA', type=float,
                    required=True)
    # eventID was used for MiniRun3:
    ap.add_argument('--event-id-var', help='Name of event ID variable',
                    choices=['event_id', 'eventID'], default='event_id')
    ap.add_argument('--nproc', help='Number of parallel processes', type=int, default=8)
    ap.add_argument('--sam', help='SAM compatibility mode (only affects checksum syntax)',
                    action='store_true')
    ap.add_argument('--parents')
    args = ap.parse_args()

    if args.one:
        dump_metadata(args.one, args)
    else:
        ext = get_ext(args)
        paths = args.all.glob(f'*.{ext}')
        pool = Pool(args.nproc)
        pool.starmap(dump_metadata,
                    [(p, args) for p in paths])


if __name__ == '__main__':
    main()
