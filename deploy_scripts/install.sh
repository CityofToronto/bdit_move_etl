#!/bin/bash
# shellcheck disable=SC1090,SC1091

set -euo pipefail

set +u
source /home/ec2-user/.bash_profile
set -u

# section: enable_amazon_linux_extras
sudo amazon-linux-extras enable nginx1.12

# enable EPEL repo (for postgis utils, e.g. shp2pgsql)
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# section: install_base
# dependencies for Python, tippecanoe
sudo yum update -y
sudo yum install -y bzip2-devel gcc gcc-c++ jq libffi-devel nginx openssl-devel postgis postgresql postgresql-contrib postgresql-devel python-devel readline-devel sqlite-devel zlib-devel

# section: pre_install_flashcrow
## /install_node.sh
if command -v nvm > /dev/null 2>&1; then
  echo "nvm already installed, skipping..."
else
  echo "installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash
  # ensure that nvm shims are available in current shell session
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# confirm
echo "$NVM_DIR"

# install correct version of node
echo "installing node@lts/*..."
nvm install lts/*
echo "lts/*" > /home/ec2-user/.nvmrc
nvm use lts/*

# section: pre_install_flashcrow
## /install_python.sh
if command -v pyenv; then
  echo "pyenv already installed, skipping..."
else
  echo "installing pyenv..."
  git clone https://github.com/pyenv/pyenv.git "$HOME/.pyenv"
  cat <<'EOF' >> "$HOME/.bashrc"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
EOF
  set +u
  # shellcheck disable=SC1090
  . "$HOME/.bashrc"
  set -u
fi

# install correct version of Python
echo "installing Python 3.7.2..."
pyenv install -s 3.7.2
pyenv rehash
pyenv global 3.7.2
pip install --upgrade pip

# install tippecanoe
if command -v tippecanoe; then
  echo "tippecanoe already installed, skipping..."
else
  git clone https://github.com/mapbox/tippecanoe.git "$HOME/tippecanoe"
  cd "$HOME/tippecanoe"
  make -j
  sudo make install
fi

# set up Airflow
mkdir -p "$HOME/airflow"
# shellcheck disable=SC2016
echo 'export AIRFLOW_HOME="$HOME/airflow"' >> "$HOME/.bashrc"
# shellcheck disable=SC1090
set +u
. "$HOME/.bashrc"
set -u

# link DAGs
ln -s /home/ec2-user/move_etl/scripts/airflow/dags /home/ec2-user/airflow/dags
