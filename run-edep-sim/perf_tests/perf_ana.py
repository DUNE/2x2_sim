#!/usr/bin/env python3

from glob import glob
# from math import ceil, floor

import matplotlib.pyplot as plt
import numpy as np


NTASKS = [64, 128, 192, 256]
# NTASKS = [64, 128]


def parse_timestr(timestr):
    "Convert output of /usr/bin/time into minutes"
    parts = timestr.split(':')
    if len(parts) == 3:         # hh:mm:ss
        hrs, mins, secs = map(int, parts)
        return hrs*60 + mins + secs/60
    else:
        assert(len(parts) == 2)
        mins = int(parts[0])
        secs, millisecs = map(int, parts[1].split('.'))
        return mins + secs/60 + millisecs/60_000


def parse_timefile(path: str):
    lines = open(path).readlines()
    timestrs = [line.split()[-1] for line in lines]
    return sum(parse_timestr(ts) for ts in timestrs)


def get_times(outname):
    timedir = f'../output/{outname}/TIMING'
    files = glob(f'{timedir}/*.time')
    times = np.array([parse_timefile(f) for f in files])
    # times = times[np.nonzero(times)]
    return times


def hist_times(divide_by_ntasks=False):
    all_times = [get_times(f'NuMI_RHC_CHERRY_{n}tasks')
                 for n in NTASKS]
    if divide_by_ntasks:
        all_times = [times / ntasks
                     for times, ntasks in zip(all_times, NTASKS)]

    min_time = min(min(times) for times in all_times)
    max_time = max(max(times) for times in all_times)

    print(min_time, max_time)

    # bins = np.linspace(min_time, max_time, 21)

    for i, n in enumerate(NTASKS):
        # plt.hist(all_times[i], bins=bins)
        plt.hist(all_times[i], range=(min_time, max_time), bins=20,
                 histtype='step', density=True, label=f'{n} tasks')

    # plt.hist(all_times, bins=20, histtype='step', density=True,
    #          label=[f'{n} tasks' for n in NTASKS])

    plt.legend()
    if divide_by_ntasks:
        plt.xlabel('Runtime/ntasks [minutes]')
    else:
        plt.xlabel('Runtime [minutes]')
    plt.title('GENIE + edep-sim runtime vs parallelism')
    plt.tight_layout()
    plt.savefig(f'gfx/times{"_divided" if divide_by_ntasks else ""}.png')


def get_avgtimes():
    result = {}
    for n in NTASKS:
        times = get_times(f'NuMI_RHC_CHERRY_{n}tasks')
        times /= n
        times = times[np.nonzero(times)]
        result[n] = times.mean()
    return result
