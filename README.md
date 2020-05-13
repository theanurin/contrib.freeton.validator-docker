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

## Quick Start

1. Docker Host check list:

	* [ ] - Empty directory for global configuration, let's say `/ton/etc`
	* [ ] - Empty directory for TON database, let's say `/ton/db`
	
	According [recommendations](https://github.com/tonlabs/main.ton.dev/) you need 1000 GB (prefer SSD) for the database directory.

1. Fetch latest version of the image

	```bash
	docker fetch cexiolabs/freeton-validator
	```

1. Start a container

	```bash
	docker fetch cexiolabs/freeton-validator
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

	```

## What the image includes

* Patches for [ton-blockchain/ton](https://github.com/ton-blockchain/ton) sources that uses inside TON Labs [build scripts](https://github.com/tonlabs/main.ton.dev/tree/master/patches).
* [`x86-64`](https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options) build of [ton-blockchain/ton](https://github.com/ton-blockchain/ton) sources for Alpine Linux.
* Templates of the `global.config.json` for Free TON networks: mainnet, testnet and devnet.
* Simple setup shell script.

```

```

## Advanced usage

### Build own image (performance)

It is possible to improve node perfomance if you build an image for your CPU (instead `x86-64`) by providing TON_ARCH build argument. See [GCC Options](https://gcc.gnu.org/onlinedocs/gcc-9.2.0/gcc/x86-Options.html#x86-Options) and choose correct one value `cpu-type`. If you hard to determine correct `cpu-type` just use `native`.

```bash
docker build --tag cexiolabs/freeton-validator --build-arg TON_ARCH=native --file docker/alpine/Dockerfile .
```

### Use utils

The image includes [ton-blockchain/ton](https://github.com/ton-blockchain/ton) utils like `generate-random-id`. You may use it just pass as arguments, like:
``` bash
docker run cexiolabs/freeton-validator generate-random-id --mode keys
```