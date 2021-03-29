# Validator install files
The following files are copied over to validator machines and [validator_run](./validator_run.sh) is run.

The files are 
*  [validator_run](./validator_run.sh) the one that does the install
*  [.bashrc](./.bashrc) setups up default paths
*  [terracli-server.service](./terracli-server.service) to start the LCD REST api for which the oracle will communicate to it with
*  [terrad.service](./terrad.service) the terrad service itself
*  [checksum.sh](./checksum.sh) [original](https://github.com/chainlayer/quicksync-playbooks/blob/master/roles/quicksync/files/checksum.sh) this set of scripts make use of the [quicksync](https://terra.quicksync.io/) service to speed up recovery
*  *.sum files are sha256sum files we download. we use this to verify their integrity
