# PoolTogether Custom Prize Strategy

Example project demonstrating a custom prize strategy.  Fork this project to easily create and test your own prize stratgies.

## Setup

First clone the repository then run:

```bash
$ yarn
```

Copy over .envrc.example to .envrc

```
$ cp .envrc.example .envrc
```

Make sure to update the enviroment variables with suitable values.  You'll want to administer any pools you create, so be sure to use a mnemonic that you used to create a prize pool.

Now enable the env vars using [direnv](https://direnv.net/docs/installation.html)

```
$ direnv allow
```

### Setup PoolTogether Contracts as a separate project

Clone the [PoolTogether Contracts](https://github.com/pooltogether/pooltogether-pool-contracts/tree/version-3) repository in another directory:

```
$ cd ..
$ git clone git@github.com:pooltogether/pooltogether-pool-contracts.git
$ cd pooltogether-pool-contracts
$ git checkout version-3
```

Notice that we check out the `version-3` branch.

**Follow the setup instruction in the [README](https://github.com/pooltogether/pooltogether-pool-contracts/tree/version-3)**

Now start a local node:

```
$ yarn start
```

You should now have a local node running that is fully bootstrapped with:

- PoolTogether contracts
- Mock DAI
- Mock Compound cDai
- Mock yEarn yDAI Vault

### Deploy the Custom Prize Strategy

```
$ yarn deploy-pt
```

This will compile and deploy the contracts against the local node started in the other project.

### Test it out!

Create a prize pool in the normal way, and then try swapping out the strategy!
