#!/usr/bin/env bash
cd /home/user/oracle-feeder/feeder
source /home/user/oracle_pub_key.env 
#operatorAddr="${ORACLE_PUB_KEY}"
	   #--lcd https://lcd.terra.dev \
npm start vote -- \
	   --source http://price-server-01:8532/latest \
	   --lcd http://validator-01:1317 \
	   --chain-id "${CHAIN_ID}" \
	--denoms sdr,krw,usd,mnt,eur,cny,jpy,gbp,inr,cad,chf,hkd,aud,sgd \
	--validator "${VALIDATOR_KEY}" \
	--password "${ORACLE_PASS}" \
	--gas-prices 169.77ukrw
