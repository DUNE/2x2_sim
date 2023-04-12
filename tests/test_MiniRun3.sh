#!/usr/bin/env bash

set -o errexit

( pushd run-edep-sim
  tests/test_MiniRun3.nu.edep-sim.sh
  popd
  pushd run-hadd
  tests/test_MiniRun3.nu.hadd.sh
  popd ) &

( pushd run-edep-sim
  tests/test_MiniRun3.rock.edep-sim.sh
  popd
  pushd run-hadd
  tests/test_MiniRun3.rock.hadd.sh
  popd ) &

wait

pushd run-spill-build
tests/test_MiniRun3.spill-build.sh
popd

pushd run-convert2h5
tests/test_MiniRun3.convert2h5.sh
popd

pushd run-larnd-sim
tests/test_MiniRun3.larnd-sim.sh
popd
