#!/usr/bin/env bash
source settings.default
source settings.private

validator=$(gcloud compute ssh --ssh-key-file=./setup_key_private user@validator-${CHAIN_ID}-01 -- -q terrad tendermint show-validator) 
validator=$(echo $validator | tr -d '\r')

#
# congratulations for reading things before blindly applying them! you could have just sent a few luna to me.     

terracli tx staking create-validator --pubkey ${validator} \
     --amount "${VALIDATOR_AMOUNT}" \
     --from validator \
     --commission-rate="${COMMISSION_RATE}" \
     --commission-max-rate="${COMMISSION_MAX_RATE}" \
     --commission-max-change-rate="${COMMISSION_MAX_CHANGE_RATE}" \
     --min-self-delegation "${VALIDATOR_SELF_DELEGATE}" \
     --moniker "${MONIKER}" \
     --chain-id "${CHAIN_ID}" \
     --details "Setup using PFC scripts. https://github.com/PFC-Validator/terra-scripts " \
     --memo "setup using PFC. Thank you" \
     --gas-prices="1.5uluna" --gas-adjustment=1.4 -y
 
 #terracli tx staking edit-validator \
 #    --from validator \
 #    --moniker "${MONIKER}" \
 #    --chain-id "${CHAIN_ID}" \
 #    --security-contact "none-set@example.com" \
 #    --details "Setup using PFC scripts."  \
 #    --memo "hi mom"  -y \
 #    --fees "3000uluna"
