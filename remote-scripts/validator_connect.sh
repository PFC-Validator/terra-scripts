#!/usr/bin/env bash
source settings.default
source settings.private
echo "this establishes a local port on your local machine. please use a different window with terracli"
terracli config node http://127.0.0.1:26657
terracli config chain-id ${CHAIN_ID}

gcloud compute ssh user@validator-${CHAIN_ID}-01 --ssh-key-file=./setup_key_private -- -L26657:127.0.0.1:26657 -L1317:127.0.0.1:1317
