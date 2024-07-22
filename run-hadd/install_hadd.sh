#!/usr/bin/env bash


rm getGhepPOT.exe


g++ -o getGhepPOT.exe getGhepPOT.C `root-config --cflags --glibs`


exit
