#!/usr/bin/env bash

set -e
set -x

sudo yum update
sudo yum install -y boost-filesystem boost-regex boost-serialization
