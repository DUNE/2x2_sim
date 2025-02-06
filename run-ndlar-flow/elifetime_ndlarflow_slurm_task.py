#!/usr/bin/env python3

import os
import sys


SLURM_NNODES = int(os.environ['SLURM_NNODES'])
SLURM_NTASKS_PER_NODE = int(os.environ['SLURM_NTASKS_PER_NODE'])
SLURM_NODEID = int(os.environ['SLURM_NODEID'])
SLURM_LOCALID = int(os.environ['SLURM_LOCALID']) # the local task ID on the node
GLOBAL_TASK_ID = SLURM_NODEID * SLURM_NTASKS_PER_NODE + SLURM_LOCALID


def main():
    input_file_list = sys.argv[1]

    input_files = open(input_file_list).readlines()
    files_per_task = len(input_files) // SLURM_NTASKS_PER_NODE

    start_idx = GLOBAL_TASK_ID * files_per_task
    end_idx = start_idx + files_per_task

    for idx in range(start_idx, end_idx):
        filename = input_files[idx].strip()
        os.system(f'./run_ndlar_flow_test_simple_edepsim.sh {filename}')


if __name__ == '__main__':
    main()
