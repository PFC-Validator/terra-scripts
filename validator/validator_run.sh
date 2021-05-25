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
    "bombay-0005")
	sudo cp validator/terrad.service /etc/systemd/system/
	;;
    *)
	sudo cp validator/*.service /etc/systemd/system/
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
# TBD do a checksum check
# curl -LO https://golang.org/dl/go1.16.2.linux-amd64.tar.gz
# tar xfz ./go1.16.2.linux-amd64.tar.gz
curl -LO https://golang.org/dl/go1.15.12.linux-amd64.tar.gz
if ! sha256sum -c validator/go1.15.12.linux-amd64.tar.gz.sum ; then
    echo "GO download did not match checksum"
    exit 1
fi
tar xfz ./go1.15.12.linux-amd64.tar.gz
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
# TBD: currently pulls 'master', should it pull v0.4.6 ?
git clone https://github.com/terra-project/core/
cd core
case "${CHAIN_ID}" in 
    "bombay-0005")
	git checkout v0.5.0-beta1
	;;
    *)
	git checkout v0.4.6
	;;
esac


#
# should this use cleveldb
# go build -tags cleveldb
make install
# terraD binaries are in the right place now
terrad init "${MONIKER}" --chain-id ${CHAIN_ID}
if [ -f ".terrad/config/genesis.json" ];
then
    rm -f .terrad/config/genesis.json 
fi 

case "${CHAIN_ID}" in 
    "Columbus-4") 
        echo "Columbia not supported yet"
        curl https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/genesis.json > $HOME/.terrad/config/genesis.json
        curl https://network.terra.dev/addrbook.json > $HOME/.terrad/config/addrbook.json
        # TBD is address.json actually needed?

        ;;
    "tequila-0004")
        curl https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/genesis.json > $HOME/.terrad/config/genesis.json
        curl https://raw.githubusercontent.com/terra-project/testnet/master/tequila-0004/address.json > $HOME/.terrad/config/address.json
        curl https://network.terra.dev/testnet/addrbook.json > $HOME/.terrad/config/addrbook.json
        ;;
    "bombay-0005")
        curl https://raw.githubusercontent.com/terra-project/testnet/master/bombay-0005/genesis.json > $HOME/.terra/config/genesis.json
#        curl https://raw.githubusercontent.com/terra-project/testnet/master/bombay-0005/address.json > $HOME/.terra/config/address.json
#        curl https://network.terra.dev/testnet/addrbook.json > $HOME/.terrad/config/addrbook.json
	;;
    *)
        echo "${CHAIN_ID} not known"
        exit 1
    ;;
esac 
case "${CHAIN_ID}" in 
    "bombay-0005")
	pushd ${HOME}/.terra
	;;
    *)
	pushd ${HOME}/.terrad
	;;
esac


#pushd ${HOME}
cp ./config/config.toml ./config/config.toml.orig
# sed script to fix indexer line to 'null'
# sed 's/indexer = \"kv\"/indexer = \"null\"/' < .terrad/config/config.toml.orig > .terrad/config/config.toml.1 
sed 's/\"data/\"\/mnt\/disks\/data\/terrad\/data/' < ./config/config.toml.orig > ./config/config.toml.1
case "${CHAIN_ID}" in 
    "Columbus-4") 
        echo "Columbia not supported yet"
        sed 's/seeds = \"\"/seeds = \"20271e0591a7204d72280b87fdaa854f50c55e7e@106.10.59.48:26656,3b1c85b86528d10acc5475cb2c874714a69fde1e@110.234.23.153:26656,49333a4cb195d570ea244dab675a38abf97011d2@13.113.103.57:26656,7f19128de85ced9b62c3947fd2c2db2064462533@52.68.3.126:26656\"/' < ./config/config.toml.1 > ./config/config.toml
        ;;
    "tequila-0004")
        sed 's/seeds = \"\"/seeds = \"341f51bf381566dfef0fc345c2aa882cbeebd320@public-seed2.terra.dev:36656\"/' < ./config/config.toml.1 > ./config/config.toml
        ;;
    "bombay-0005")
        sed 's/seeds = \"\"/seeds = \"eb4168239744007adcce028a397fc2addf4b2520@54.150.118.40:36656,2e13408cbe993a291caf02946e902753f7f95a71@3.34.120.243:26656,67f83663158a908b1a0784e642eafde880dd2929@65.21.157.38:26656,f9cb325f1ca9296c2853c2f416991e34927e23f7@207.180.213.123:26656,c7fdeca4135e56149f5f5d84462c9eb9f059edb8@52.78.140.220:26656,bdc57c5a7f11040bed560fceb7d9b17c117e3423@193.239.85.118:26656\"/' < ./config/config.toml.1 > ./config/config.toml
        ;;
    *)
        echo "${CHAIN_ID} not known"
        exit 1
    ;;  
esac

# app.toml
cp ./config/app.toml ./config/app.toml.orig
sed 's/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.01133uluna,0.15uusd,0.104938usdr,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek\"/' < ./config/app.toml.orig > ./config/app.toml

popd
case "${CHAIN_ID}" in 
    "bombay-0005")
	echo "skipping terracli as it isn't installed"
	;;
    *)
	terracli config node http://127.0.0.1:26657
	terracli config chain-id ${CHAIN_ID}
	;;
esac


chmod 700 ${HOME}/validator/checksum.sh


pushd /mnt/disks/data/terrad 
case "${CHAIN_ID}" in 
    "Columbus-4") 
        echo "Columbia not supported yet"
        syncfile=$( curl https://terra.quicksync.io/sync.json|jq -r ".[]| select(.network==\"pruned\")|.file" |grep columbus-4)
        echo "syncfile = ${syncfile}"
        aria2c  -x5 https://get.quicksync.io/${syncfile}
        curl -O  https://get.quicksync.io/${syncfile}.checksum
        hash=$(curl -s https://get.quicksync.io/${syncfile}.hash)
        curl -s https://lcd.terra.dev/txs/${hash}|jq -r '.tx.value.memo'|sha512sum -c
        ${HOME}/validator/checksum.sh ${syncfile}

        echo "exit code $?"
        echo "waiting..."
        read

	mv ${HOME}/.terrad/data ${HOME}/.terrad/data.orig
	ln -s /mnt/disks/data/terrad/data ${HOME}/.terrad/
        ;;
    "tequila-0004")
       # syncfile=tequila-4.20210215.tar.lz4
        syncfile=$( curl https://terra.quicksync.io/sync.json|jq -r ".[]| select(.network==\"default\")|.file" |grep tequila-4)
        echo "syncfile = ${syncfile}"
        #aria2c -x5 https://get.quicksync.io/${syncfile} -o sync.lz4 
        aria2c  -x5 https://get.quicksync.io/${syncfile}
        curl -O  https://get.quicksync.io/${syncfile}.checksum
        hash=$(curl -s https://get.quicksync.io/${syncfile}.hash)
        # Note: this is stored on mainnet. this is not a bug
        curl -s https://lcd.terra.dev/txs/${hash} |jq -r '.tx.value.memo'|sha512sum -c
        ${HOME}/validator/checksum.sh ${syncfile}
        pv ${syncfile} | lz4 -dc | tar xf -
        # tar --use-compress-program=lz4 -xf ${syncfile}

	mv ${HOME}/.terrad/data ${HOME}/.terrad/data.orig
	ln -s /mnt/disks/data/terrad/data ${HOME}/.terrad/
        ;;
    "bombay-0005")
#	mkdir /mnt/disks/data/terrad/data
	echo "${CHAIN_ID} no syncing available"
	mv ${HOME}/.terra/data ${HOME}/.terra/data.orig
	ln -s /mnt/disks/data/terrad/data ${HOME}/.terra/
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
sudo systemctl enable terrad 
case "${CHAIN_ID}" in 
    "bombay-0005")
	echo "terracli-server needs to be enabled in [api] section"
	;;
    *)
	sudo systemctl enable terracli-server
	;;
esac

echo "Remember to hand-edit /etc/stackdriver/collectd.conf Interval for non-prod boxes"
# and machine is ready to rock&roll.
sudo reboot
