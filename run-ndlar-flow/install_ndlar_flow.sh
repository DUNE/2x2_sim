#!/usr/bin/env bash

# install h5flow
git clone git@github.com:peter-madigan/h5flow.git
cd h5flow
pip install .
cd ..

# install ndlar_flow
git clone git@github.com:larpix/ndlar_flow.git
cd ndlar_flow
pip install .
cd ..
