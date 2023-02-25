#!/usr/bin/env bash

## Run me from inside the container

edepfile=$1; shift

scl enable devtoolset-7 bash

root -l -b -q $edepfile -e '_file0->MakeProject("libTG4Event", "*", "RECREATE++")'
