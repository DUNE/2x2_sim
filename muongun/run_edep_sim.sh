#!/usr/bin/env bash

source muongun_vars.inc.sh

genieFile=gntp.0.gtrac.root

rootCode='
auto t = (TTree*) _file0->Get("gRooTracker");
std::cout << t->GetEntries() << std::endl;'
nEvents=$(echo "$rootCode" | root -l -b "$genieFile" | tail -1)

edepCode="/generator/kinematics/rooTracker/input $genieFile"

time edep-sim -C -g "$ARCUBE_GEOM" -o edep.root -e "$nEvents" \
    <(echo "$edepCode") "$ARCUBE_EDEP_MAC"
