scripts I use to control the setup.
configuration settings are stored in settings.private
please look at [settings.default](settings.default) for what is needed.
you should edit/change things in settings.private 

Files:
* [create_vms.sh](./create_vms.sh) this should set up the 3 VMs required 
* [delete_vms.sh](./delete_vms.sh) should remove EVERYTHING and leave you with a clean slate. this is a hard-erase. everything will be gone. so be careful
* [setup_firewall.sh](./setup_firewall.sh) configures incoming ports. 
* [setup_key.sh](./setup_key.sh) generates a ssh-key. GCP does a lot of this automagically, but I'm old school.
* [setup_validator.sh](./setup_validator.sh) copies the validator files over, and kicks off the [validator install](../validator/validator_run.sh)
* [validator_connect.sh](./validate_connect.sh) establishes a port forward between your local machine and the validator. This allows you to run terracli commands locally
* [validator_status.sh](./validate_status.sh) just connects to the validator and runs a status

