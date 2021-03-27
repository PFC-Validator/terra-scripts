#!/usr/bin/env bash
source settings.default
source settings.private
if [ -f ${SSH_KEY_FILE} ]; then
    echo "cowardly refusign to overwrite your key file."
    echo "please manualy remove ${SSH_KEY_FILE} and repeat."
    echo "^c to interrupt. otherwise it will continue with this file"
    read 
else 
ssh-keygen -f ${SSH_KEY_FILE} -t ed25519 -b 521 -C user
fi 
ssh-add ${SSH_KEY_FILE}