#!/usr/bin/env bash

set -e

sudo apt-get -y -qq install jq

wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py