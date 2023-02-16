#!/usr/bin/env python3

import os
from subprocess import call

from fireworks.core.firework import FiretaskBase, FWAction

class EdepSimTask(FiretaskBase):
    _fw_name = "Edep-sim task"

    def run_task(self, fw_spec):
        env = os.environ | {k: str(v) for k, v in fw_spec.items()
                            if k.startswith('ARCUBE_')}

        # container digest 1079ee4e88
        shifter = 'shifter --image=docker:wilkinsonnu/nuisance_project:2x2_sim_prod'
        call(f'{shifter} -- ./fw_edep_sim.sh', shell=True,
             cwd=fw_spec['ARCUBE_BASE'], env=env)

        return FWAction()
