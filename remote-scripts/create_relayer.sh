#!/usr/bin/env bash
source settings.default
source settings.private
current_project=$(gcloud config get-value project )
vm_type="projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2004-focal-v20211209"

echo "Using Project ID ${current_project} to create VMs in zone ${DEFAULT_ZONE}"
echo "waiting for confirmation. <enter> to continue, ^C to abort"
read

email=$(gcloud iam service-accounts list --filter display_name='feeder' --format="value(email)")


gcloud compute instances create relayer-001 \
    --image=${vm_type} \
    --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --machine-type ${MACHINE_TYPE} \
    --tags=relayer &

#gcloud compute disks create relayer-001-data \
#  --size ${VALIDATOR_DISK_SIZE} \
#  --zone ${DEFAULT_ZONE} \
#  --type ${VALIDATOR_DISK_TYPE} &
 
  
wait

#gcloud compute instances attach-disk validator-pfc --disk validator-pfc-data --zone ${DEFAULT_ZONE}
#gcloud compute instances attach-disk validator-tb --disk validator-tb-data --zone europe-north1-c
