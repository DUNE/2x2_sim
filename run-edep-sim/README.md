# One-time overall setup

First, manually clone larnd-sim somewhere. Before submitting jobs, point
`LARND_SIM` to this location. We're only using `cli/dumpTree.py`, so don't need
Numba etc.

Then run `./init_venv.sh` to prepare a Python virtual environment containing
dependencies of `dumpTree.py`.

# One-time setup for each geometry/tune combo

``` shell
./GENIE_max_path_length_gen.sh geometry/Merged2x2MINERvA_noRock.gdml G18_10a_02_11a
```

Here the geometry and tune were taken from `submit_example.sh`.

# Submitting the example

``` shell
export LARND_SIM=/path/to/larnd-sim
./submit_example.sh
```
