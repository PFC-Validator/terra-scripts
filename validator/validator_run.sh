#!/bin/bash
#
MONIKER=$1
CHAIN_ID=$2

# setup the drive
sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
sudo mkdir -p /mnt/disks/data
sudo mount -o discard,defaults /dev/sdb /mnt/disks/data
sudo mkdir -p /mnt/disks/data/terrad
sudo chown user /mnt/disks/data/terrad
#called data as the quicksync expects it to be in data
mkdir -p /mnt/disks/data/terrad/data
UUID=$(sudo blkid /dev/sdb |cut -d " " -f2| sed s/\"//g )
echo "$UUID /mnt/disks/data ext4 discard,defaults,nofail 0 2" >> /tmp/fstab.add 
cat /etc/fstab /tmp/fstab.add > /tmp/fstab 
sudo cp /tmp/fstab /etc/fstab 

# setup the limits
sudo cp validator/limits.terrad /etc/security/limits.d/limits.terrad 
# install the service definitions
sudo cp validator/*.service /etc/systemd/system/

# additional stuff required on the box
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y build-essential git jq liblz4-tool aria2

# GO .. as we're building it from source.
# TBD do a checksum check
curl -LO https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
tar xfz ./go1.16.2.linux-amd64.tar.gz
sudo mv go /usr/local

# set up paths for next time
mv validator/.bashrc ${HOME}
chmod 755 ${HOME}/.bashrc
export GOPATH=${HOME}/go
export PATH=${PATH}:/usr/local/go/bin:${PWD}/go/bin

# get the code
git clone https://github.com/terra-project/core/
cd core
make install
# terraD binaries are in the right place now
terrad init ${MONIKER} --chain-id ${CHAIN_ID}
rm -f .terrad/config/genesis.json 
# curl https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/genesis.json > $HOME/.terrad/config/genesis.json
curl https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/genesis.json > $HOME/.terrad/config/genesis.json
curl https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/address.json > $HOME/.terrad/config/address.json

cp .terrad/config/config.toml .terrad/config/config.toml.orig
# sed script to fix indexer line to 'null'
sed 's/indexer = \"kv\"/indexer = \"null\"/' < .terrad/config/config.toml.orig > .terrad/config/config.toml.1 
sed 's/db_dir = \"data\"/db_dir = \"\/mnt\/disks\/data\/terrad\/data\"/' < .terrad/config/config.toml.1 > .terrad/config/config.toml
terracli config node http://127.0.0.1:26657
terracli config chain-id ${CHAIN_ID}

#
#syncfile=$( curl https://terra.quicksync.io/sync.json|jq -r ".[]| select(.network==\"pruned\")|.file" |grep columbus-4)
syncfile=tequila-4.20210215.tar.lz4
cd /mnt/disks/data/terrad 
aria2c --continue -x5 https://get.quicksync.io/${syncfile} -o sync.lz4 
lz4 -d sync.lz4 |tar xf -
# everything is in place ..
# lighting up daemons
sudo systemctl daemon-reload
sudo systemctl enable terrad 
sudo systemctl enable terracli-server
# and machine is ready to rock&roll.
sudo reboot