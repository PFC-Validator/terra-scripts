#!/bin/bash
#
CURRENCYLAYER_APIKEY=$1



# setup the limits
sudo cp price-server/limits.terrad /etc/security/limits.d/terrad.conf
# install the service definitions
sudo cp price-server/*.service /etc/systemd/system/

# Google's monitoring agent 
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh 
sudo bash add-monitoring-agent-repo.sh 
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh 

# NodeJS
# TODO SECURITY replace with better way
curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -
# additional stuff required on the box
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y build-essential git jq liblz4-tool aria2 net-tools vim 'stackdriver-agent=6.*'
# logging stuff
sudo apt-get install -y google-fluentd 
sudo apt-get install -y google-fluentd-catch-all-config 
sudo service google-fluentd start
sudo apt-get install -y nodejs


# set up paths for next time
mv price-server/.bashrc ${HOME}
chmod 755 ${HOME}/.bashrc

git clone https://github.com/terra-project/oracle-feeder.git
pushd oracle-feeder/price-server
npm install
# Copy sample config file
# TODO SED
sed "0,/apiKey:/{s/apiKey: ''/apiKey: '${CURRENCYLAYER_APIKEY}'/}" < ./config/default-sample.js > ./config/default.js.1
sed "s/'KRW\/THB',/'KRW\/TBH','KRW\/SEK',/" < ./config/default.js.1 > ./config/default.js
popd
mv price-server/price-server-start.sh oracle-feeder/price-server

# lighting up daemons
sudo systemctl daemon-reload
sudo systemctl enable terrad-price-server

# and machine is ready to rock&roll.
sudo reboot
