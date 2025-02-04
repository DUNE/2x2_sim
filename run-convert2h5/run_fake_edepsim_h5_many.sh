#!/usr/bin/env bash
set -o errexit

for i in $(seq 0 99); do
    ARCUBE_INDEX=$i ./run_make_simple_events_h5.sh &
done

wait