# EIP2535 Diamond Foundry deployment script

Example Foundry deployment script for EIP-2535 Diamond standard implementation (diamond-1).

#### Prerequisites

This is a Foundry project, therefore you must first install Foundry on your machine:
[Install Foundry](https://book.getfoundry.sh/getting-started/installation)

You'll also need [JQ](https://jqlang.github.io/jq/).


### Setup

```bash
git clone https://github.com/NaviNavu/diamond-1-foundry.git
cd diamond-1-foundry
forge install
forge build 
```

Then you can run the tests:
```bash
forge test --ffi
```
The `--ffi` option is required as the deployment script will recover the facets function selectors from the JSON artifacts generated at build time via a bash script using JQ.
For example, the `DiamondLoupeFacet` functions selectors are recovered from `/out/DiamondLoupeFacet.sol/DiamondLoupeFacet.json`.

 
### Deploying locally
#### .env file
To deploy locally with *Anvil*, make sure you provided a `LOCAL_DEPLOYER_PRIVATE_KEY` in the `.env` file prior to running the deployment script.
The ownership of the deployed Diamond is assigned to `LOCAL_DEPLOYER_PRIVATE_KEY` address.
You can use a private key provided by Anvil.

Check the **[Foundry Book](https:book.getfoundry.shtutorialssolidity-scripting#deploying-locally)** for more info and methods.

#### To deploy the Diamond locally on the Anvil environment with `LOCAL_DEPLOYER_PRIVATE_KEY` as deployer and Diamond owner:

Start Anvil:
```bash
anvil
```

Then run Forge' `script` command to run the `DeployDiamond` script and deploy the Diamond on the local Anvil environment:

```bash
forge script script/DeployDiamond.s.sol:DeployDiamond \
--ffi \
--fork-url http:localhost:8545 \
--broadcast
```

### Example interactions with Cast

Querying for the Diamond owner address:

```bash
cast call $DIAMOND_ADDRESS "owner()" --rpc-url http://localhost:8545
```

Transfering the Diamond ownership:

```bash 
cast send $DIAMOND_ADDRESS \
"transferOwnership(address)" $NEW_OWNER_ADDRESS \
--private-key $PRIVATE_KEY \
--rpc-url http://localhost:8545
```

### Deploying on testnet and mainnet

To run the deployment script on testnet or mainnet, follow the [FoundryBook](https://book.getfoundry.sh/tutorials/solidity-scripting#deploying-our-contract) security recommendations, steps to configure your environment and run the deployment script.
