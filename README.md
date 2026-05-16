## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage
### MultiSigWallet deployed at: 0xfBc0e3CcEf40756701173a22F0AfC16F2D7e4829

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
### Owner exporting owner
```
$ export OWNER1=0x6firstaddress                                                        
export OWNER2=0xsecondaddress                                                                   
export OWNER3=0xthirdaddress
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```
### other choice of deploy 
```shell
$ export SEPOLIA_RPC="uour_rpc_url"  # or your Infura/public endpoint
$ export PRIVATE_KEY=your_private_key
$ forge script script/Deploy.s.sol:DeployMultiSig --rpc-url $SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
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
