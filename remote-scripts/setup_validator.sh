#!/usr/bin/env bash
source settings.default
source settings.private
gcloud compute scp --scp-flag=-r ../validator/ user@validator-02: --ssh-key-file=./setup_key_private
gcloud compute ssh user@validator-02 --ssh-key-file=./setup_key_private --  ./validator/validator_run.sh ${MONIKER} ${CHAIN_ID}