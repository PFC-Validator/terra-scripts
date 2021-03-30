# Price Server install files
The price server talks to 3rd party currency services

The following files are copied over to feeder machines and [price-server_run](./price-server_run.sh) is run.

The files are 
* [price-server_run](./price-server_run.sh) the one that does the install
* [.bashrc](./.bashrc) setups up default paths
* [price-server-start.sh](./price-server-start.sh) starts the price server service
* [terrad-price-server.service](./terrad-price-server.service) the terrad price server service itself
