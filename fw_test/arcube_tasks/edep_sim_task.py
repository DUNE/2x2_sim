#!/usr/bin/env python3

import os
from subprocess import Popen

from fireworks.core.firework import FiretaskBase, FWAction

class EdepSimTask(FiretaskBase):
    _fw_name = "Edep-sim task"

    def run_task(self, fw_spec):
        env = os.environ | {k: str(v) for k, v in fw_spec.items()
                            if k.startswith('ARCUBE_')}

        # XXX run the script in Shifter

        print(f'hello python {fw_spec["ARCUBE_BASE"]}')

        Popen('./fw_edep_sim.sh', cwd=fw_spec['ARCUBE_BASE'], env=env)

        return FWAction()
