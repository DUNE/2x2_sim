# One-time overall setup

Currently no need to install larnd-sim since we use Callum's modified
dumpTree.py (different method of getting the TG4Event branch out of the tree).
The version in larnd-sim crashes in this container.

# One-time setup for each geometry/tune combo

``` shell
./GENIE_max_path_length_gen.sh geometry/Merged2x2MINERvA_noRock.gdml G18_10a_02_11a
```

Here the geometry and tune were taken from `submit_example.sh`.

# Submitting the example

``` shell
# export LARND_SIM=/path/to/larnd-sim     # currently not necessary
./submit_example.sh
```

# Ignore the following

First, manually clone larnd-sim somewhere. Before submitting jobs, point
`LARND_SIM` to this location. We're only using `cli/dumpTree.py`, so don't need
Numba etc.

Run `./init_venv.sh` to prepare a Python virtual environment containing
dependencies of `dumpTree.py`. (Not needed for Callum's version)
