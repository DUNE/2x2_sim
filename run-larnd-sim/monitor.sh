#!/usr/bin/env bash

while true; do
    top ibn1
    # top -u $UID -b -n 1
    nvidia-smi
    printf "\n-oOo-\n"
    sleep 60
done
