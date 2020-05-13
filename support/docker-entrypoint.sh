#!/bin/sh
#

set -e

case "$1" in
	validator-engine) ;;
	*) exec $* ;;
esac


# Right not only "validator-engine" supported

if [ -f /BANNER ]; then
	echo
	cat /BANNER
	echo
fi

if [ -d /etc/ton ] && [ -d /var/ton ] && etcfiles=$(ls -1AL -- /etc/ton) && datafiles=$(ls -1AL -- /var/ton) && [ -z "$etcfiles" ] && [ -z "${datafiles}" ]; then
	echo "Directories /etc/ton and /var/ton are empty. Looks like this is a first launch. Entering setup mode..."

	umask 0027

	# Setup /etc/ton/global.config.json
	while true; do
		echo
		echo "Please select template of global.config.json. See section 'Global configuration of the TON Blockchain' of the https://test.ton.org/FullNode-HOWTO.txt"
		echo
		for GLOBAL_CONFIG_TEMPLATE in $(ls -1 /usr/local/share/ton); do
			echo "	${GLOBAL_CONFIG_TEMPLATE}"
		done
		unset GLOBAL_CONFIG_TEMPLATE
		echo
		read -p "Enter template file name: " GLOBAL_CONFIG_TEMPLATE
		if [ -f "/usr/local/share/ton/${GLOBAL_CONFIG_TEMPLATE}" ]; then
			break;
		fi
	done
	echo "	/usr/local/share/ton/${GLOBAL_CONFIG_TEMPLATE} -> /etc/ton/global.config.json"
	cp "/usr/local/share/ton/${GLOBAL_CONFIG_TEMPLATE}" /etc/ton/global.config.json
	unset GLOBAL_CONFIG_TEMPLATE

	# Public IP
	while true; do
		echo
		read -p "Enter your external IPv4 address for this TON node (like 1.2.3.4): " INTERNET_EXPOSE_IP
		if ipcalc -ms "${INTERNET_EXPOSE_IP}" >/dev/null; then
			break
		fi
	done

	# Choose ADNL_PORT
	while true; do
		echo
		read -p "Enter ADNL port (like 30310): " ADNL_PORT
		if expr "${ADNL_PORT}" : '[1-9][0-9]*$' >/dev/null; then
			break
		fi
	done

	echo
	echo "Launching validator-engine to generate instance configuration..."
	/usr/local/bin/validator-engine --db /var/ton --global-config /etc/ton/global.config.json --ip "${INTERNET_EXPOSE_IP}:${ADNL_PORT}"

	echo
	echo "Generating keys for server, liteserver and client(validator-engine-console)..."
	mkdir /etc/ton/keys
	cd /etc/ton/keys
	/usr/local/bin/generate-random-id --mode keys --name client > /etc/ton/keys/keys_c
	/usr/local/bin/generate-random-id --mode keys --name liteserver > /etc/ton/keys/keys_l
	/usr/local/bin/generate-random-id --mode keys --name server > /etc/ton/keys/keys_s
	cd - > /dev/null
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

	chown root:ton -R /etc/ton
	chown -R ton /var/ton
fi

exec /usr/local/bin/validator-engine --db /var/ton --global-config /etc/ton/global.config.json --user ton