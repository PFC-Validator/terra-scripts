#!/usr/bin/env bash
source settings.default
source settings.private
#echo "type in your wallet password"
VALIDATOR_KEY=$(terracli keys show validator --bech=val -a ) 
ORACLE_KEY=$( terracli keys show oracle -a) 
key_exists=$(gcloud secrets list --filter ORACLE_PASSWORD --format=json)
if [ "$key_exists" == "[]" ];
then
    printf "${ORACLE_PASSWORD}" | gcloud secrets create ORACLE_PASSWORD --data-file=-
else
    printf "${ORACLE_PASSWORD}" | gcloud secrets versions add ORACLE_PASSWORD --data-file=-
fi
#terracli tx oracle set-feeder <feeder-address> --from=<validator>
terracli tx oracle set-feeder ${ORACLE_KEY} --from=validator --fees="30000uluna"
gcloud compute scp --scp-flag=-r ../feeder/ user@feeder-${CHAIN_ID}-01: --ssh-key-file=./setup_key_private
gcloud compute ssh user@feeder-${CHAIN_ID}-01 --ssh-key-file=./setup_key_private --  ./feeder/feeder_run.sh ${CHAIN_ID} ${VALIDATOR_KEY}

