# Mineable-404

Mineable-404 is the worlds first POW mineable ERC404 token.

Mined using PoW through a SmartContract
* No pre-mine
* No ICO
* 21,000,000 tokens total (in homage to Bitcoin)
* Difficulty target auto-adjusts with PoW hashrate
* Rewards decrease as more tokens are minted
* Compatible with all services that support ERC20 tokens


## Setup


### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
