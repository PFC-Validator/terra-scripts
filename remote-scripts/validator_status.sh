#!/usr/bin/env bash
source settings.default
source settings.private
status=$(gcloud compute ssh user@validator-01 -- terracli status )
echo ${status} | jq
