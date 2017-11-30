#!/bin/bash

[[ -f /etc/os-release ]] && . /etc/os-release

if [[ "${ID}" == "opensuse" ]]; then
  sudo zypper install -y ca-certificates \
    curl \
    libffi-devel \
    libopenssl-devel \
    libyaml-devel \
    patterns-devel-C-C++-devel_C_C++ \
    python-devel \
    python-pip \
    python-setuptools
  sudo bash -lc 'zypper install -y "rubygem(bundler)"'
  sudo ln -sf /usr/bin/pip2 /usr/bin/pip
fi

/tmp/kitchen/ansible-setup.sh
