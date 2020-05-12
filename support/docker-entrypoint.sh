#!/bin/sh
#

if [ -f /BANNER ]; then
	echo
	cat /BANNER
	echo
fi

if [ -f /etc/ton/BANNER ]; then
	echo
	cat /etc/ton/BANNER
	echo
fi

umask 0077

if [ -d /etc/ton ] && etcfiles=$(ls -1AL -- /etc/ton) && [ -z "$etcfiles" ]; then
	echo "A directory /etc/ton is empty. Entering setup mode..."

	if [ -z "${INTERNET_EXPOSE_IP}" ]; then
		echo "Setup mode requires an environment variable INTERNET_EXPOSE_IP. Please pass the environment variable INTERNET_EXPOSE_IP with your external IPv4 address for this TON node. Cannot continue." >&2
		exit 1
	fi

	echo "----------------------------" > /etc/ton/BANNER
	if [ "${NETWORK}" == "mainnet" ]; then
		echo "Setup TON Mainnet instance..."
		echo "--- TON Mainnet instance ---" >> /etc/ton/BANNER
		[ -n "${ADNL_PORT}" ] || ADNL_PORT="30310"
		cp /etc/ton.mainnet.example/global.config.json /etc/ton/global.config.json
	else
		echo "Setup TON Testnet instance..."
		echo "--- TON Testnet instance ---" >> /etc/ton/BANNER
		[ -n "${ADNL_PORT}" ] || ADNL_PORT="30310"
		cp /etc/ton.testnet.example/global.config.json /etc/ton/global.config.json
	fi
	echo "----------------------------" >> /etc/ton/BANNER

	/build/ton-blockchain/build/validator-engine/validator-engine --db /var/ton --global-config /etc/ton/global.config.json --ip "${INTERNET_EXPOSE_IP}:${ADNL_PORT}"

	mkdir /etc/ton/keys
	cd /etc/ton/keys
	/build/ton-blockchain/build/utils/generate-random-id --mode keys --name client > /etc/ton/keys/keys_c
	/build/ton-blockchain/build/utils/generate-random-id --mode keys --name liteserver > /etc/ton/keys/keys_l
	/build/ton-blockchain/build/utils/generate-random-id --mode keys --name server > /etc/ton/keys/keys_s
	cd -

	mv "/etc/ton/keys/server" "/var/ton/keyring/$(awk '{print $1}' "/etc/ton/keys/keys_s")"
	mv "/etc/ton/keys/liteserver" "/var/ton/keyring/$(awk '{print $1}' "/etc/ton/keys/keys_l")"

	awk '{
		if (NR == 1) {
			server_id = $2
		} else if (NR == 2) {
			client_id = $2
		} else if (NR == 3) {
			liteserver_id = $2
		} else {
			print $0;
			if ($1 == "\"control\"") {
				print "      {";
				print "         \"id\": \"" server_id "\","
				print "         \"port\": 3030,"
				print "         \"allowed\": ["
				print "            {";
				print "               \"id\": \"" client_id "\","
				print "               \"permissions\": 15"
				print "            }";
				print "         ]"
				print "      }";
			} else if ($1 == "\"liteservers\"") {
				print "      {";
				print "         \"id\": \"" liteserver_id "\","
				print "         \"port\": 3031"
				print "      }";
			}
		}
	}' "/etc/ton/keys/keys_s" "/etc/ton/keys/keys_c" "/etc/ton/keys/keys_l" "/var/ton/config.json" > "/var/ton/config.json.tmp"

	mv "/var/ton/config.json.tmp" "/var/ton/config.json"
fi

exec /build/ton-blockchain/build/validator-engine/validator-engine --db /var/ton --global-config /etc/ton/global.config.json

#exec /bin/sh
