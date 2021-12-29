# relayer install files
The following files are copied over to relayer machines and [relayer_run](./relayer_run.sh) is run.

The files are 
*  [relayer_run](./relayer_run.sh) the one that does the install
*  [.bashrc](./.bashrc) setups up default paths, and is appended to the standard basrc
*  [hermes.service](./hermes.service) the hermes service itself
*  *.sum files are sha256sum files we download. we use this to verify their integrity
