#!/usr/bin/env bash

module load python              # 3.9-anaconda-2021.11

rm -rf fw.venv

python -m venv fw.venv
source fw.venv/bin/activate

pip install -U pip wheel setuptools

pip install 'FireWorks[rtransfer,newt,daemon_mode,flask-plotting,workflow-checks,graph-plotting]'

# these should be automatically installed b/c of the [extras] above
# pip install matplotlib  # (only needed for seeing visual report plots in web gui!)
# pip install paramiko  # (only needed if using built-in remote file transfer!)
# pip install fabric  # (only needed if using daemon mode of qlaunch!)
# pip install requests  # (only needed if you want to use the NEWT queue adapter!)
# # follow instructions to install argcomplete library if you want auto-complete of FWS commands
# pip install argcomplete

# cd fw_venv/lib/python3.*/site-packages
# ln -s ../../../../arcube_tasks .

# install arcube_tasks
pip install -e .

confdir=$(realpath config)
sed "s%{CONFIG_FILE_DIR}%$confdir%" config/templates/FW_config.template.yaml > config/FW_config.yaml
[[ ! -e config/my_launchpad.yaml ]] && cp config/templates/my_launchpad.template.yaml config/my_launchpad.yaml

echo "Remember to edit the password in config/my_launchpad.yaml"
