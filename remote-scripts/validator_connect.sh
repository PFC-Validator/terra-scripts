#!/usr/bin/env bash
source settings.default
source settings.private
echo "this establishes a local port on your local machine. please use a different window with terracli"
terracli config node http://127.0.0.1:16657
terracli config chain-id ${CHAIN_ID}

gcloud compute ssh user@validator-01 --ssh-key-file=./setup_key_private -- -L16657:127.0.0.1:26657