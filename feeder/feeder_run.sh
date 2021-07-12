#!/bin/bash
#

CHAIN_ID=$1
VALIDATOR_KEY=$2

#TODO use GCP security
echo "CHAIN_ID=${CHAIN_ID}" > ${HOME}/oracle_pub_key.env 
chmod 600  ${HOME}/oracle_pub_key.env 
echo "VALIDATOR_KEY=${VALIDATOR_KEY}" >> ${HOME}/oracle_pub_key.env 
#echo "ORACLE_PASS=${ORACLE_PASS}" >> ${HOME}/oracle_pub_key.env 
ORACLE_PASS=$(gcloud secrets versions access latest --secret ORACLE_PASSWORD)
# setup the limits
sudo cp feeder/limits.terrad /etc/security/limits.d/terrad.conf
# install the service definitions
sudo cp feeder/*.service /etc/systemd/system/

# Google's monitoring agent 
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh 
sudo bash add-monitoring-agent-repo.sh 
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh 

# NodeJS
# TODO SECURITY replace with better way
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
# additional stuff required on the box
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y build-essential git jq liblz4-tool aria2 net-tools vim 'stackdriver-agent=6.*'
# logging stuff
sudo apt-get install -y google-fluentd 
sudo apt-get install -y google-fluentd-catch-all-config 
sudo service google-fluentd start
sudo apt-get install -y nodejs

git clone https://github.com/terra-project/oracle-feeder.git
pushd oracle-feeder/feeder
npm install

echo "please use password ORACLE_PASS"
echo "and your oracle words"
npm start update-key
popd
mv feeder/start-feeder.sh oracle-feeder/feeder

# lighting up daemons
sudo systemctl daemon-reload
sudo systemctl enable terrad-oracle-feeder

# and machine is ready to rock&roll.
sudo reboot
