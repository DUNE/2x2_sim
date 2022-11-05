#!/usr/bin/env bash

module load python              # 3.9-anaconda-2021.11

rm -rf fw_venv

python -m venv fw_venv
source fw_venv/bin/activate

pip install -U pip wheel setuptools

pip install FireWorks

pip install matplotlib  # (only needed for seeing visual report plots in web gui!)
pip install paramiko  # (only needed if using built-in remote file transfer!)
pip install fabric  # (only needed if using daemon mode of qlaunch!)
pip install requests  # (only needed if you want to use the NEWT queue adapter!)
# follow instructions to install argcomplete library if you want auto-complete of FWS commands
pip install argcomplete

cd fw_venv/lib/python3.*/site-packages
ln -s ../../../../arcube_tasks .
