#!/usr/bin/env python3

import argparse
import os


HADD_FACTOR = 10

PREAMBLE = """\
#include "NDCAFMaker.fcl"

nd_cafmaker: @local::standard_nd_cafmaker

"""


def get_path(base_dir, step, name, ftype, ext, file_id: int):
    subdir = file_id // 1000 * 1000
    subdir = f'{subdir:07d}'
    # Temporary special case for Minerva
    ftype2 = ftype
    ftype2 = 'dst' if ftype == 'DST' else ftype2 
    ftype2 = 'SPINE' if ftype == 'MLRECO_ANALYSIS' else ftype2 
    path = (f'{base_dir}/{step}/{name}/{ftype}/{subdir}' +
            f'/{name}.{file_id:07d}.{ftype2}.{ext}')
    if not os.path.exists(path):
        print(f'WHERE THE HECKING HECK IS {path}')
        raise
    return path


def write_ghep_files(outf, base_dir, name, file_id: int, no_final_comma=False):
    for ghep_id in range(file_id * HADD_FACTOR, (file_id+1) * HADD_FACTOR):
        path = get_path(base_dir, 'run-genie', name, 'GHEP', 'root', ghep_id)
        is_last = ghep_id == (file_id+1) * HADD_FACTOR - 1
        maybe_comma = '' if (no_final_comma and is_last) else ','
        outf.write(f'   "{path}"{maybe_comma}\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--base-dir', required=True)
    ap.add_argument('--ghep-nu-name', required=True)
    ap.add_argument('--ghep-rock-name', required=True)
    ap.add_argument('--spine-name', required=True)
    ap.add_argument('--minerva-name', required=True)
    ap.add_argument('--edepsim-name', required=False)
    ap.add_argument('--caf-path', required=True)
    ap.add_argument('--cfg-file', required=True)
    ap.add_argument('--file-id', required=True, type=int)
    args = ap.parse_args()

    with open(args.cfg_file, 'w') as outf:
        outf.write(PREAMBLE)

        outf.write('nd_cafmaker.CAFMakerSettings.GHEPFiles: [\n')
        write_ghep_files(outf, args.base_dir, args.ghep_nu_name, args.file_id)
        outf.write('\n')
        write_ghep_files(outf, args.base_dir, args.ghep_rock_name, args.file_id,
                         no_final_comma=True)
        outf.write(']\n\n')

        ## We pass the full CAF path since we initially output to a tmpdir
        # caf_path = get_path(args.base_dir, 'run-cafmaker', args.caf_name,
        #                     'CAF', 'root', args.file_id)
        caf_path = args.caf_path
        outf.write(f'nd_cafmaker.CAFMakerSettings.OutputFile: "{caf_path}"\n')

        spine_path = get_path(args.base_dir, 'run-spine', args.spine_name,
                               'MLRECO_ANALYSIS', 'hdf5', args.file_id)
        outf.write(f'nd_cafmaker.CAFMakerSettings.NDLArRecoFile: "{spine_path}"\n')

        minerva_path = get_path(args.base_dir, 'run-minerva', args.minerva_name,
                                'DST', 'root', args.file_id)
        outf.write(f'nd_cafmaker.CAFMakerSettings.MINERVARecoFile: "{minerva_path}"\n')
        print("edepsim path" ,args.base_dir, args.edepsim_name)
        edepsim_path = get_path(args.base_dir, 'run-spill-build', args.edepsim_name,
                                'EDEPSIM_SPILLS','root',args.file_id) 
        outf.write(f'nd_cafmaker.CAFMakerSettings.EdepsimFile: "{edepsim_path}"\n')

if __name__ == '__main__':
    main()
