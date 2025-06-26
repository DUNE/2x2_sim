#!/usr/bin/env python3

import argparse
import os


PREAMBLE = """\
#include "NDCAFMaker.fcl"

nd_cafmaker: @local::standard_nd_cafmaker

"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--spine-path', required=False)
    ap.add_argument('--pandora-path', required=False)
    ap.add_argument('--minerva-path', required=False)
    ap.add_argument('--caf-path', required=True)
    ap.add_argument('--cfg-file', required=True)
    ap.add_argument('--disable-ifbeam', action='store_true')
    args = ap.parse_args()

    with open(args.cfg_file, 'w') as outf:
        outf.write(PREAMBLE)

        caf_path = args.caf_path
        outf.write(f'nd_cafmaker.CAFMakerSettings.OutputFile: "{caf_path}"\n')

        if args.spine_path:
            outf.write(f'nd_cafmaker.CAFMakerSettings.NDLArRecoFile: "{args.spine_path}"\n')

        if args.pandora_path:
            outf.write(f'nd_cafmaker.CAFMakerSettings.PandoraLArRecoNDFile: "{args.pandora_path}"\n')

        if args.minerva_path:
            outf.write(f'nd_cafmaker.CAFMakerSettings.MINERVARecoFile: "{args.minerva_path}"\n')

        if args.disable_ifbeam:
            outf.write('nd_cafmaker.CAFMakerSettings.ForceDisableIFBeam: true\n')

        outf.write('nd_cafmaker.CAFMakerSettings.TriggerMatchDeltaT: 5000000\n')


if __name__ == '__main__':
    main()
