#!/bin/bash
#
MONIKER=$1
CHAIN_ID=$2

echo "${MONIKER}"
echo "${CHAIN_ID}"
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
sudo cp validator/limits.terrad /etc/security/limits.d/terrad.conf
# install the service definitions
case "${CHAIN_ID}" in 
    "bombay-12")
	sudo cp validator/terrad.service /etc/systemd/system/
	;;
    *)
	sudo cp validator/terrad.service /etc/systemd/system/
	#sudo cp validator/*.service /etc/systemd/system/
	;;
esac

# Google's monitoring agent 
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh 
sudo bash add-monitoring-agent-repo.sh 
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh 

# additional stuff required on the box
sudo apt-get update && sudo apt-get upgrade -y
# libleveldb-dev is needed if we want to build terrad with cleveldb. should be harmless otherwise
sudo apt-get install -y build-essential git jq pv libleveldb-dev liblz4-tool aria2 net-tools vim 'stackdriver-agent=6.*'
# logging stuff
sudo apt-get install -y google-fluentd 
sudo apt-get install -y google-fluentd-catch-all-config 
sudo service google-fluentd start
# GO .. as we're building it from source.
curl -LO https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
#curl -LO https://golang.org/dl/go1.16.8.linux-amd64.tar.gz

if ! sha256sum -c validator/go1.16.8.linux-amd64.tar.gz.sum ; then
    echo "GO download did not match checksum"
    exit 1
fi
 #tar xfz go1.17.8.linux-amd64.tar.gz
tar xfz ./go1.16.8.linux-amd64.tar.gz
if [ -d "/usr/local/go" ]; 
then
    sudo rm -rf /usr/local/go
fi
sudo mv go /usr/local

# set up paths for next time
mv validator/.bashrc ${HOME}
chmod 755 ${HOME}/.bashrc
export GOPATH=${HOME}/go
export PATH=${PATH}:/usr/local/go/bin:${PWD}/go/bin

# get the code

git clone https://github.com/terra-money/core/
cd core
case "${CHAIN_ID}" in 
    "bombay-12")
	git checkout v0.5.17
	;;
    *)
	git checkout v0.5.17
	;;
esac


#
# should this use cleveldb
# go build -tags cleveldb
make install
# terraD binaries are in the right place now
terrad init "${MONIKER}" --chain-id ${CHAIN_ID}
if [ -f ".terra/config/genesis.json" ];
then
    rm -f .terra/config/genesis.json 
fi 

case "${CHAIN_ID}" in 
    "columbus-5") 
        echo "Columbus-5 not supported yet"
	# TBD
#        curl https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/genesis.json > $HOME/.terrad/config/genesis.json
#        curl https://network.terra.dev/addrbook.json > $HOME/.terrad/config/addrbook.json
        # TBD is address.json actually needed?

        ;;
    "bombay-12")
#        curl https://raw.githubusercontent.com/terra-project/testnet/master/bombay-9/genesis.json > $HOME/.terra/config/genesis.json
	curl https://raw.githubusercontent.com/terra-money/testnet/master/bombay-12/genesis.json > $HOME/.terra/config/genesis.json
	;;
    *)
        echo "${CHAIN_ID} not known"
        exit 1
    ;;
esac 
case "${CHAIN_ID}" in 
    "bombay-12")
	pushd ${HOME}/.terra
	;;
    *)
	pushd ${HOME}/.terra
	;;
esac


#pushd ${HOME}
cp ./config/config.toml ./config/config.toml.orig
# sed script to fix indexer line to 'null'
# sed 's/indexer = \"kv\"/indexer = \"null\"/' < .terrad/config/config.toml.orig > .terrad/config/config.toml.1 
sed 's/\"data/\"\/mnt\/disks\/data\/terrad\/data/' < ./config/config.toml.orig > ./config/config.toml.1
case "${CHAIN_ID}" in 
    "columbus-5") 
        echo "Columbia not supported yet"
        sed 's/seeds = \"\"/seeds = \"20271e0591a7204d72280b87fdaa854f50c55e7e@106.10.59.48:26656,3b1c85b86528d10acc5475cb2c874714a69fde1e@110.234.23.153:26656,49333a4cb195d570ea244dab675a38abf97011d2@13.113.103.57:26656,7f19128de85ced9b62c3947fd2c2db2064462533@52.68.3.126:26656,87048bf71526fb92d73733ba3ddb79b7a83ca11e@13.124.78.245:26656\"/' < ./config/config.toml.1 > ./config/config.toml
        ;;
    "bombay-12")
        sed 's/seeds = \"\"/seeds = \"8eca04192d4d4d7da32149a3daedc4c24b75f4e7@3.34.163.215:26656\"/' < ./config/config.toml.1 > ./config/config.toml
        ;;
    *)
        echo "${CHAIN_ID} not known"
        exit 1
    ;;  
esac

# app.toml
cp ./config/app.toml ./config/app.toml.orig
sed 's/minimum-gas-prices = \"\"/minimum-gas-prices=\"0.01133uluna,0.104938usdr,0.15uusd,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek,1.25unok,0.9udkk,2180.0uidr,7.6uphp,1.17uhkd,0.6umyr,4.0utwd\"/' < ./config/app.toml.orig > ./config/app.toml


popd
#case "${CHAIN_ID}" in 
#    "bombay-12")
#	echo "skipping terracli as it isn't installed"
#	;;
#    *)
#	terracli config node http://127.0.0.1:26657
#	terracli config chain-id ${CHAIN_ID}
#	;;
#esac


chmod 700 ${HOME}/validator/checksum.sh


pushd /mnt/disks/data/terrad 
case "${CHAIN_ID}" in 
    "columbus-5") 
        echo "Columbia not supported yet"
#        syncfile=$( curl https://terra.quicksync.io/sync.json|jq -r ".[]| select(.network==\"pruned\")|.file" |grep columbus-4)
#        echo "syncfile = ${syncfile}"
#        aria2c  -x5 https://get.quicksync.io/${syncfile}
#        curl -O  https://get.quicksync.io/${syncfile}.checksum
#        hash=$(curl -s https://get.quicksync.io/${syncfile}.hash)
#        curl -s https://lcd.terra.dev/txs/${hash}|jq -r '.tx.value.memo'|sha512sum -c
#        ${HOME}/validator/checksum.sh ${syncfile}
#        tar -I lz4 -xf columbus-5-pruned.20220320.0410.tar.lz4

#        echo "exit code $?"
#        echo "waiting..."
#        read

	mv ${HOME}/.terra/data ${HOME}/.terra/data.orig
	ln -s /mnt/disks/data/terrad/data ${HOME}/.terra/
	cp ${HOME}/.terra/data.orig/priv_validator_state.json ${HOME}/.terra/data/
        ;;
    "bombay-12")
#	mkdir /mnt/disks/data/terrad/data
	echo "${CHAIN_ID} no syncing available"
	mv ${HOME}/.terra/data ${HOME}/.terra/data.orig
	ln -s /mnt/disks/data/terrad/data ${HOME}/.terra/
	cp ${HOME}/.terra/data.orig/priv_validator_state.json ${HOME}/.terra/data/
	;;
    *)
        echo "${CHAIN_ID} not known"
        exit 1
    ;;  
esac
popd


#mv ${HOME}/.terrad/data/priv_validator_state.json /mnt/disks/data/terrad/data
# everything is in place ..
# lighting up daemons
sudo systemctl daemon-reload
#sudo systemctl enable terrad 
case "${CHAIN_ID}" in 
    "bombay-12")
	echo "terracli-server needs to be enabled in [api] section"
	;;
    *)
	echo "terracli-server needs to be enabled in [api] section"
#	sudo systemctl enable terracli-server
	;;
esac

echo "Remember to hand-edit /etc/stackdriver/collectd.conf Interval for non-prod boxes"
# and machine is ready to rock&roll.
#sudo reboot
