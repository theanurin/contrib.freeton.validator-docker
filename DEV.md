```bash
docker build --tag cexiolabs/ton-node --file docker/alpine/Dockerfile . && docker run --tty --interactive --rm --env INTERNET_EXPOSE_IP=X.X.X.X cexiolabs/ton-node
```

* Source of patches/0001-Fix-for-neighbours-unreliability.patch: https://github.com/tonlabs/main.ton.dev/blob/6e4c842aceb2c52229730cab0fd394a4ae944e84/patches/0001-Fix-for-neighbours-unreliability.patch
* Source of support/mainnet/global.config.json: https://github.com/tonlabs/main.ton.dev/blob/6e4c842aceb2c52229730cab0fd394a4ae944e84/configs/ton-global.config.json
* Source of support/testnet/global.config.json: https://github.com/tonlabs/net.ton.dev/blob/19e5706a8bb20825998ebfdcf2ebb66e7077d583/configs/ton-global.config.json