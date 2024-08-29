#!/usr/bin/env python3

import argparse
import os


PREAMBLE = """\
#include "NDCAFMaker.fcl"

nd_cafmaker: @local::standard_nd_cafmaker

"""


def get_path(base_dir, step, name, ftype, ext, file_id: int):
    subdir = file_id // 1000 * 1000
    subdir = f'{subdir:07d}'
    # Temporary special case for Minerva
    ftype2 = 'dst' if ftype == 'DST' else ftype
    path = (f'{base_dir}/{step}/{name}/{ftype}/{subdir}' +
            f'/{name}.{file_id:07d}.{ftype2}.{ext}')
    if not os.path.exists(path):
        print(f'WHERE THE HECKING HECK IS {path}')
        raise
    return path


def write_ghep_files(outf, base_dir, name, hadd_factor, file_id: int, no_final_comma=False):
    for ghep_id in range(file_id * hadd_factor, (file_id+1) * hadd_factor):
        path = get_path(base_dir, 'run-genie', name, 'GHEP', 'root', ghep_id)
        is_last = ghep_id == (file_id+1) * hadd_factor - 1
        maybe_comma = '' if (no_final_comma and is_last) else ','
        outf.write(f'   "{path}"{maybe_comma}\n')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--base-dir', required=True)
    ap.add_argument('--ghep-nu-name', required=False)
    ap.add_argument('--ghep-rock-name', required=False)
    ap.add_argument('--mlreco-name', required=True)
    ap.add_argument('--minerva-name', required=False)
    ap.add_argument('--caf-path', required=True)
    ap.add_argument('--cfg-file', required=True)
    ap.add_argument('--file-id', required=True, type=int)
    ap.add_argument('--hadd-factor', required=False, default=10, type=int)
    args = ap.parse_args()

    if not args.ghep_nu_name and not args.ghep_rock_name:
        raise ValueError("One or both of ghep-nu-name and ghep-rock-name must be specified")

    with open(args.cfg_file, 'w') as outf:
        outf.write(PREAMBLE)

        outf.write('nd_cafmaker.CAFMakerSettings.GHEPFiles: [\n')
        if args.ghep_nu_name:
            write_ghep_files(outf, args.base_dir, args.ghep_nu_name, args.hadd_factor, args.file_id, not args.ghep_rock_name)
            outf.write('\n')
        if args.ghep_rock_name:
            write_ghep_files(outf, args.base_dir, args.ghep_rock_name, args.hadd_factor, args.file_id,
                             no_final_comma=True)
        outf.write(']\n\n')

        ## We pass the full CAF path since we initially output to a tmpdir
        # caf_path = get_path(args.base_dir, 'run-cafmaker', args.caf_name,
        #                     'CAF', 'root', args.file_id)
        caf_path = args.caf_path
        outf.write(f'nd_cafmaker.CAFMakerSettings.OutputFile: "{caf_path}"\n')

        mlreco_path = get_path(args.base_dir, 'run-mlreco', args.mlreco_name,
                               'MLRECO_ANA', 'hdf5', args.file_id)
        outf.write(f'nd_cafmaker.CAFMakerSettings.NDLArRecoFile: "{mlreco_path}"\n')

        if args.minerva_name:
            minerva_path = get_path(args.base_dir, 'run-minerva', args.minerva_name,
                                    'DST', 'root', args.file_id)
            outf.write(f'nd_cafmaker.CAFMakerSettings.MINERVARecoFile: "{minerva_path}"\n')


if __name__ == '__main__':
    main()
