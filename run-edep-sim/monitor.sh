#!/usr/bin/env bash

while true; do
    # top ibn1
    top -u $UID -b -n 1
    sleep 10
done
