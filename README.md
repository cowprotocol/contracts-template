# Contract Template

Template for creating new smart contract projects.

This project is meant to be used as a templated during the creation of new Github repositories (will show in the `Create a new repository > Configuration > Start with a template` selector).

It will contain some useful configuration files and scripts, that can be used also with existing projects (manually copied).

## Usage

### Make targets

To see all available make targets, run:

```shell
make help
```

### Deploy

Add `--broadcast` to send the transaction. Add `--verify` to verify the contract using the Etherscan settings in `foundry.toml`.

```shell
forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## New project creation checklist

The following operations need to be performed after this repository has been created.

- [ ] In GitHub repo settings:
  - [ ] Add a new ruleset called "Protected branches" and include the following changes:
    - Enforcement status: active
    - Target branches: Include default branch
    - Require linear history
    - Require a pull request before merging
      - Required approvals: 1
      - Allowed merge methods: Squash
    - Block force pushes
  - [ ] In General → Features → Pull requests:
    - Select "Pull request title and description" in "Default commit message" option
    - Unckeck "Allow merge commits" option
    - Check "Allow auto-merge" option
  - [ ] Configure secrets in the repository settings (e.g. `ETH_RPC_URL`):
    - In Settings → Secrets and variables → Actions → New repository secret
    - Uncomment the `env` section in `.github/workflows/ci.yml` to use secrets in the CI workflow
- [ ] Initialize the submodules with `git submodule update --init`
- [ ] Install the dependencies with `forge install`. This will create a new `foundry.lock` file which you should commit to the project
- [ ] Make sure you use the [latest version of Solidity](https://github.com/argotorg/solidity/releases) by updating the `solc` version in `foundry.toml`
- [ ] Install `solhint` globally with `npm i -g solhint`
- [ ] Install `slither` globally with `pipx install slither-analyzer==0.11.0`. This will create a new `slither.config.json` file which you should commit to the project
- [ ] Install the pre-commit hooks with `pre-commit install`
- [ ] Once all entries in this list are checked, delete this section from the readme
