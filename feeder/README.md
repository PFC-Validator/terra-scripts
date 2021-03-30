# Feeder install files
The feeder oracle talks to internal currency service

The following files are copied over to feeder machines and [feeder_run](./feeder_run.sh) is run.

The files are 
* [feeder_run](./feeder_run.sh) the one that does the install
* [.bashrc](./.bashrc) setups up default paths
* [start-feeder.sh](./start-feeder.sh) starts the feeder service
* [terrad-oracle-feeder.service](./terrad-oracle-feeder.service) the terrad feeder service itself
