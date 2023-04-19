#! /bin/bash
# use like ` ./install-go 1.20.1 `
# use proxy  ` ./install-go 1.20.1 `
source common.sh
check

version=$1
src=$2

official="https://go.dev/dl/go"${version}".${os}-${arch}.tar.gz"
google="https://dl.google.com/go/go"${version}".${os}-${arch}.tar.gz"

# download
if [ "${src}" == "" ]; then
  wget -c "${google}" -O - | sudo tar -xzv -C /usr/local
elif [ "${src}" == "official" ]; then
  wget -c "${official}" -O - | sudo tar -xzv -C /usr/local
elif [ "${src}" == "google" ]; then
  wget -c "${google}" -O - | sudo tar -xzv -C /usr/local
fi

# add $PATH
which go
if [ $? -ne 0  ]; then
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
  source ~/.profile
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.zshrc
  source ~/.zshrc
fi

go version