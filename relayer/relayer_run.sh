#!/bin/bash
#

CHAIN_ID=$2


echo "${CHAIN_ID}"

# setup the limits
#sudo cp relayer/limits.terrad /etc/security/limits.d/terrad.conf
# install the service definitions
# Google's monitoring agent 
sudo su -c "echo 'deb http://packages.cloud.google.com/apt google-compute-engine-focal-stable main' > /etc/apt/sources.list.d/google-compute-engine.list"
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt update
sudo apt-get upgrade -y
sudo apt -y install google-osconfig-agent


# additional stuff required on the box
#sudo apt-get update && sudo apt-get upgrade -y
# libleveldb-dev is needed if we want to build terrad with cleveldb. should be harmless otherwise
sudo apt-get install -y build-essential git jq pv libleveldb-dev liblz4-tool aria2 net-tools vim pkg-config libssl-dev
#'stackdriver-agent=6.*'
# logging stuff
sudo apt-get install -y google-fluentd 
sudo apt-get install -y google-fluentd-catch-all-config 
sudo service google-fluentd start
# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# GO .. as we're building it from source.

curl -LO https://golang.org/dl/go1.16.8.linux-amd64.tar.gz

if ! sha256sum -c relayer/go1.16.8.linux-amd64.tar.gz.sum ; then
    echo "GO download did not match checksum"
    exit 1
fi
tar xfz ./go1.16.8.linux-amd64.tar.gz
if [ -d "/usr/local/go" ]; 
then
    sudo rm -rf /usr/local/go
fi
sudo mv go /usr/local
cat < relayer/.bashrc >> .bashrc

export GOPATH=${HOME}/go
export PATH=${PATH}:/usr/local/go/bin:${PWD}/go/bin

# prereq's are done.. let's install it
cargo install ibc-relayer-cli --bin hermes --locked
mkdir .hermes
copy relayer/config.toml .hermes/
# and machine is ready to rock&roll.
cat << EOF
# remember to set your pruning settings to your node's app.toml"

pruning = "custom"

# These are applied if and only if the pruning strategy is custom.
pruning-keep-recent = "400000"
pruning-keep-every = "0"
pruning-interval = "10"
EOF
#sudo reboot
