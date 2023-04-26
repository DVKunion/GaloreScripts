#! /bin/bash

# provide some common check func
os=""
arch=""

check() {
  check_os
  check_arch
}

check_os() {
  if [ "$(uname)" == "Darwin" ]; then
    os="darwin"
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    os="linux"
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    os="windows"
  fi
  echo "system os: ${os}"
}

check_arch() {
  if [[ $(arch) =~ "x86_64" ]]; then
    arch="386"
  elif [[ $(arch) =~ "aarch64" || $(arch) =~ "arm64" ]]; then
    arch="arm64"
  elif [[ $(arch) =~ "amd64" ]]; then
    arch="amd64"
  fi
  echo "system arch: ${arch}"
}
