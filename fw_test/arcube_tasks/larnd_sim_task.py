#!/usr/bin/env python3

import os
from subprocess import call

from fireworks.core.firework import FiretaskBase, FWAction

class LArNDSimTask(FiretaskBase):
    _fw_name = "larnd-sim task"

    def run_task(self, fw_spec):
        env = os.environ | {k: str(v) for k, v in fw_spec.items()
                            if k.startswith('ARCUBE_')}

        call(f'./fw_larnd_sim.sh', shell=True,
             cwd='../run_larnd_sim', env=env)

        return FWAction()
