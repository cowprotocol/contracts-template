# Contract Template

Template for creating new smart contract projects.

This project is meant to be used as a templated during the creation of new Github repositories (will show in the `Create a new repository > Configuration > Start with a template` selector).

It will contain some useful configuration files and scripts, that can be used also with existing projects (manually copied).


## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Deploy

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```
