#!/usr/bin/env bash
source settings.default
source settings.private
gcloud compute scp --scp-flag=-r ../price-server/ user@price-server-01: --ssh-key-file=./setup_key_private
gcloud compute ssh user@price-server-01 --ssh-key-file=./setup_key_private --  ./price-server/price-server_run.sh ${CURRENCYLAYER_APIKEY}