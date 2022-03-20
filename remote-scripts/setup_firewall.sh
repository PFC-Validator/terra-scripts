#!/usr/bin/env bash
source settings.default
source settings.private

# TODO confirm 1317 is still accessible internally
gcloud compute firewall-rules create "validator-rule-ipc" \
   --network=default \
   --allow=tcp:26656 \
   --target-tags validator &
gcloud compute firewall-rules create "validator-rule-relay" \
   --network=default \
   --allow=tcp:26657,tcp:9090 \
   --target-tags validator &

#   --source-tags relayer \
# For now we use a portforward to get to 26657
#gcloud compute firewall-rules create "validator-rule-ctrl" \
#   --network=default \
#   --allow=tcp:26657 \
#   --source-tags ctrl \
#   --target-tags validator &

gcloud compute firewall-rules create "validator-rule-rest" \
   --network=default \
   --allow=tcp:1317 \
   --source-tags oracle \
   --target-tags validator &

gcloud compute firewall-rules create "priceserver-rule-rest" \
   --network=default \
   --allow=tcp:8532 \
   --source-tags oracle \
   --target-tags priceserver &

wait 

gcloud compute networks subnets update default --region=${DEFAULT_REGION} --enable-private-ip-google-access
