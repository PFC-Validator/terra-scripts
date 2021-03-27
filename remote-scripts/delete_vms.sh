#!/usr/bin/env bash
echo "this will delete everything"
echo "there is no going back"
read
yes|gcloud compute instances delete validator-01 &
yes|gcloud compute instances delete oracle-01 &
yes|gcloud compute instances delete feeder-01 &
yes | gcloud compute firewall-rules delete validator-rule-ipc &
yes | gcloud compute firewall-rules delete validator-rule-rest &
yes | gcloud compute firewall-rules delete feeder-rule-rest &
wait 