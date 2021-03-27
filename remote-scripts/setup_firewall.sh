#!/usr/bin/env bash
source settings.default
source settings.private

# TODO confirm 1317 is still accessible internally
gcloud compute firewall-rules create "validator-rule-ipc" \
   --network=default \
   --allow=tcp:26656 \
   --target-tags validator &
gcloud compute firewall-rules create "validator-rule-rest" \
   --network=default \
   --allow=tcp:1317 \
   --source-tags oracle \
   --target-tags validator &
gcloud compute firewall-rules create "feeder-rule-rest" \
   --network=default \
   --allow=tcp:8532 \
   --source-tags oracle \
   --target-tags feeder & 
wait 
#gcloud compute firewall-rules create --network=default  allow-node-ipc --allow=tcp:1317

#ssh user@validator-01 --ssh-key-file=${SSH_KEY_FILE}