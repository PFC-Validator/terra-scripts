# Validator install files
The following files are copied over to validator machines and [validator_run](./validator_run.sh) is run.

The files are 
*  [validator_run](./validator_run.sh) the one that does the install
*  [.bashrc](./bashrc) setups up default paths
*  [terracli-server.service](./terracli-server.service) to start the LCD REST api for which the oracle will communicate to it with
*  [terrad.service](./terrad.service) the terrad service itself
