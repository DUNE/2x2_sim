# Recording total POT in each hadded file

For the spill building stage it is necessary to know the total amount of POT in each hadded file. Unless you have no failed jobs at all, this will not simply be the `ARCUBE_HADD_FACTOR` multiplied by `ARCUBE_EXPOSURE`. At the `hadd` stage, one can set `ARCUBE_USE_GHEP_POT=1`, triggering a macro which calculates the total POT of the hadded file from the GENIE files corresponding to the hadded file's constituent EDEPSIM files. The macro is run by `run_hadd.sh` as compiled c++. The `.exe` must be generated and can be done in one step.

```
shifter --image=$ARCUBE_CONTAINER --module=none /bin/bash -- ${PWD}/install_hadd.sh
```
