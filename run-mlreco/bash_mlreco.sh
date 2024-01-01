#!/usr/bin/env bash

# Spawn a shell in the mlreco environment. Useful for interactive testing.

export ARCUBE_RUNTIME=SHIFTER
export ARCUBE_CONTAINER=mjkramer/sim2x2:mlreco001

if [[ "$SHIFTER_IMAGEREQUEST" != "$ARCUBE_CONTAINER" ]]; then
    shifter --image=$ARCUBE_CONTAINER --module=cvmfs,gpu -- /bin/bash --init-file "$0"
    exit
fi

source load_mlreco.inc.sh

alias ls='ls --color=auto'
PS1='\W $ '
