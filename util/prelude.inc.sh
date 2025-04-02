#!/usr/bin/env bash

set -o errexit
set -o pipefail

setup_cuda() {
    if [[ "$LMOD_SYSTEM_NAME" == "perlmutter" ]]; then
        module load python/3.11
        module load cudatoolkit/12.4
    fi
}
