#!/usr/bin/env bash
source settings.default
source settings.private
current_project=$(gcloud config get-value project )
vm_type="projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2004-focal-v20210511"

echo "Using Project ID ${current_project} to create VMs in zone ${DEFAULT_ZONE}"
echo "waiting for confirmation. <enter> to continue, ^C to abort"
read

gcloud iam service-accounts create feeder \
 	 --description "service account to use on oracle feeder machines" 
	 --display-name="feeder"

email=$(gcloud iam service-accounts list --filter display_name='feeder' --format="value(email)")

# don't think this is required
#gcloud secrets add-iam-policy-binding my-secret2    \
#   --member="serviceAccount:${email}"  \
#   --role="roles/secretmanager.secretAccessor"

# first two are for monitoring   
gcloud projects add-iam-policy-binding ${current_project} --member="serviceAccount:${email}" --role="roles/logging.logWriter"
gcloud projects add-iam-policy-binding ${current_project} --member="serviceAccount:${email}" --role="roles/monitoring.metricWriter"
# next is to allow this service account to see secrets
gcloud projects add-iam-policy-binding ${current_project} --member="serviceAccount:${email}" --role="roles/secretmanager.secretAccessor"

#machine_image=$(gcloud compute images list --project cos-cloud --no-standard-images|grep cos-stable|cut -d " " -f1)

gcloud compute instances create validator-${CHAIN_ID}-01 \
    --image=${vm_type} \
    --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --machine-type ${VALIDATOR_MACHINE_TYPE} \
    --tags=validator &

# TODO determine if this really needs an external IP
#      --no-address \
#
gcloud compute instances create feeder-01 \
    --zone ${DEFAULT_ZONE} \
    --image=${vm_type} \
    --image-project=ubuntu-os-cloud \
    --tags=oracle \
    --service-account ${email}  \
    --scopes cloud-platform \
    --machine-type ${MACHINE_TYPE} &

# TODO determine if this really needs an external IP
gcloud compute instances create price-server-01 \
    --image=${vm_type} \
    --image-project=ubuntu-os-cloud \
    --zone ${DEFAULT_ZONE} \
    --tags=priceserver \
    --machine-type ${MACHINE_TYPE} &

gcloud compute disks create validator-${CHAIN_ID}-01-disk \
  --size ${VALIDATOR_DISK_SIZE} \
  --type ${VALIDATOR_DISK_TYPE} &
  
wait

gcloud compute instances attach-disk validator-${CHAIN_ID}-01 --disk validator-${CHAIN_ID}-01-disk
