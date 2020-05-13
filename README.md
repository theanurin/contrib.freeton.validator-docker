[![docker image badge](https://images.microbadger.com/badges/image/cexiolabs/freeton-validator.svg)](https://hub.docker.com/r/cexiolabs/freeton-validator)
[![ton commit badge](https://images.microbadger.com/badges/commit/cexiolabs/freeton-validator.svg)](https://github.com/ton-blockchain/ton)

# Free TON Validator
TON (Telegram Open Network) use the principle «Proof of Stake». This requires the use of masternodes. Third-party developers (validators) are owners of Masternodes.

This image was make especially for launch [Free TON Network](https://freeton.org/).

## Quick Reference
* [Free TON Community](https://freeton.org/)
* [The Declaration
of Decentralization](https://freeton.org/dod)
* [Join the Community channel](https://t.me/ton_crystal_news)
* [Join the Contest channel](https://t.me/ton_contests)
* [TON Live explorer](https://ton.live/main)
* [TON Full Node HOWTO](https://test.ton.org/FullNode-HOWTO.txt)
* [Image Maintaner Support channel](https://t.me/cexiolabs)

## Quick Start

1. Docker Host check list:

	* [ ] - Empty directory for global configuration, let's say `/ton/etc`
	* [ ] - Empty directory for TON database, let's say `/ton/db`
	
	According [recommendations](https://github.com/tonlabs/main.ton.dev/) you need 1000 GB (prefer SSD) for the database directory.

1. Fetch latest version of the image

	```bash
	docker pull cexiolabs/freeton-validator
	```

1. Start a container

	```bash
	docker run --interactive --tty --network host --mount "source=/ton/etc,target=/etc/ton" --mount "source=/ton/db,target=/var/ton" cexiolabs/freeton-validator
	```

	On first launch the container will enter into setup mode, due your directories `/ton/etc` and `/ton/db` are empty. Let answer for a few questions:

	* Choose template of global.config.json
	* Enter your public IP address (v4 only right now)
	* Enter ADNL port

	Setup script will create minimal configuration for choosen network and generate id keys.

	See [Advanced Usage section](#advanced-usage) to make this job by hand.

	Expected result:
	```
	Directories /etc/ton and /var/ton are empty. Looks like this is a first launch. Entering setup mode...

	Please select template of global.config.json. See section 'Global configuration of the TON Blockchain' of the https://test.ton.org/FullNode-HOWTO.txt

			freeton-devnet
			freeton-mainnet
			freeton-testnet

	Enter template file name [freeton-testnet]: 
			/usr/local/share/ton/freeton-testnet-global.config.json -> /etc/ton/global.config.json

	Enter your external IPv4 address for this TON node [94.154.221.168]: 

	Enter ADNL port [30310]: 

	Launching validator-engine to generate instance configuration...
	[ 3][t 1][1589413681.457912922][validator-engine.cpp:1160][!validator-engine]   no init block in config. using zero state
	[ 1][t 1][1589413681.465116262][validator-engine.cpp:1445][!validator-engine]   created config file '/var/ton/config.json'
	[ 1][t 1][1589413681.465180159][validator-engine.cpp:1446][!validator-engine]   check it manually before continue

	Generating keys for server, liteserver and client(validator-engine-console)...

	Starting Validator Engine...
	[ 3][t 1][1589413681.505045414][validator-engine.cpp:1160][!validator-engine]   no init block in config. using zero state
	[ 3][t 1][1589413681.536607504][manager.cpp:1429][!manager]     failed to load blocks from import dir: [PosixError : No such file or directory : 2 : File "/var/ton/import" can't be opened for reading]
	[ 3][t 4][1589413681.584379911][manager-init.cpp:35][!reiniter] init_block_id=[ w=-1 s=9223372036854775808 seq=0 ...
	...
	```

## What the image includes

* Patches for [ton-blockchain/ton](https://github.com/ton-blockchain/ton) sources that uses inside TON Labs [build scripts](https://github.com/tonlabs/main.ton.dev/tree/master/patches).
* [`x86-64`](https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options) build of [ton-blockchain/ton](https://github.com/ton-blockchain/ton) sources for Alpine Linux.
* Templates of the `global.config.json` for Free TON networks: mainnet, testnet and devnet.
* Simple setup shell script.

```
/
├── BANNER
└── usr
    └── local
        ├── bin
        │   ├── docker-entrypoint.sh
        │   ├── generate-random-id
        │   ├── validator-engine
        │   └── validator-engine-console
        └── share
            └── ton
                ├── freeton-devnet-global.config.json
                ├── freeton-mainnet-global.config.json
                └── freeton-testnet-global.config.json
```

## Advanced usage

### Build own image (performance)

It is possible to improve node perfomance if you build an image for your CPU (instead `x86-64`) by providing TON_ARCH build argument. See [GCC Options](https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options) and choose correct one value `cpu-type`. If you hard to determine correct `cpu-type` just use `native`.

```bash
docker build --tag cexiolabs/freeton-validator --build-arg TON_ARCH=native --file docker/alpine/Dockerfile .
```

Build variables (pass as --build-arg):
| Variable       | Default value | Description          |
|----------------|---------------|----------------------|
| TON_ARCH       | x86-64        | See [GCC Options](https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options) for `cpu-type` |
| BUILD_THREADS  | 2             | Positive integer           |
| BUILD_TYPE     | Release       | `Release` or `RelWithDebInfo`. See [notes](https://github.com/ton-blockchain/ton/blob/eecf05ca5934c8c65c8113237fa4a00adcfea697/doc/FullNode-HOWTO) for -DCMAKE_BUILD_TYPE |

### Use utils

The image includes [ton-blockchain/ton](https://github.com/ton-blockchain/ton) utils like `generate-random-id`. You may use it just pass as arguments, like:
``` bash
docker run cexiolabs/freeton-validator generate-random-id --mode keys
```