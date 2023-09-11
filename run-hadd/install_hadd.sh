#!/usr/bin/env bash


rm getGhepPOT.exe


source /environment
g++ -o getGhepPOT.exe getGhepPOT.C `root-config --cflags --glibs`


exit
