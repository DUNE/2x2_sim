#!/usr/bin/env python3

import argparse
import ruamel.yaml as yaml

from fireworks import Firework, LaunchPad, Workflow

from arcube_tasks import EdepSimTask, LArNDSimTask


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('yamlspec', type=argparse.FileType('r'))
    ap.add_argument('dk2nu_min', type=int)
    ap.add_argument('dk2nu_max', type=int)
    ap.add_argument('seed_min', type=int)
    ap.add_argument('seed_max', type=int)
    args = ap.parse_args()

    # lpad_args = yaml.safe_load(open('my_launchpad.yaml'))
    # lpad = LaunchPad(**lpad_args)
    lpad = LaunchPad.auto_load()
    base_spec = yaml.safe_load(args.yamlspec)

    for dk2nu in range(args.dk2nu_min, args.dk2nu_max+1):
        for seed in range(args.seed_min, args.seed_max+1):
            spec = base_spec | {'ARCUBE_DK2NU_INDEX': dk2nu,
                                'ARCUBE_SEED': seed}
            fw1 = Firework(EdepSimTask(), name='edep-sim',
                           spec=(spec | {'_fworker': 'fworker_edep_sim'}))
            fw2 = Firework(LArNDSimTask(), name='larnd-sim'
                           spec=(spec | {'_fworker': 'fworker_larnd_sim'}))
            wf = Workflow([fw1, fw2], {fw1: [fw2]})
            lpad.add_wf(wf)


if __name__ == '__main__':
    main()
