#!/usr/bin/env bash

# This script doesn't actually install edep-sim, since it's already installed in
# the container we're using. The name of the container is specified by the
# ARCUBE_CONTAINER environment variable, e.g. as specified in
# https://github.com/lbl-neutrino/fireworks4dune/blob/main/specs/MiniRun2/MiniRun2_1E19_RHC_nu.yaml
# The build definitions for the containers are in
# https://github.com/lbl-neutrino/2x2Containers

# HACK: Hopefully the host provides /usr/bin/time
mkdir -p tmp_bin
cp /usr/bin/time tmp_bin
