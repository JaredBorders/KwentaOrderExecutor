# foundry-scaffold

[![Github Actions][gha-badge]][gha] 
[![Foundry][foundry-badge]][foundry] 
[![License: MIT][license-badge]][license]

[gha]: https://github.com/JaredBorders/KwentaOrderExecutor/actions
[gha-badge]: https://github.com/JaredBorders/KwentaOrderExecutor/actions/workflows/test.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

## How to use
1. Clone this repo
2. Set up your environment variables (see `.env.example`)
3. Ensure you have foundry installed (see https://book.getfoundry.sh/getting-started/installation)

### Deploying to Optimism
1. Navigate to `script/Deploy.Optimism.s.sol`
2. Update 'owner' to your address (or an address you want to use to call withdraw accrued fees) **on Optimism**
3. Update 'perpsV2ExchangeRate' to the address of the PerpetualsV2ExchangeRate contract **on Optimism**
4. Follow the steps in the file to deploy the contract
5. Add the deployed contract address to your README under "Deployment Addresses"

### Deploying to Optimism Goerli
1. Navigate to `script/Deploy.OptimismGoerli.s.sol`
2. Update 'owner' to your address (or an address you want to use to call withdraw accrued fees) **on Optimism Goerli**
3. Update 'perpsV2ExchangeRate' to the address of the PerpetualsV2ExchangeRate contract **on Optimism Goerli**
4. Follow the steps in the file to deploy the contract
5. Add the deployed contract address to your README under "Deployment Addresses"

## Contracts

```
src/OrderExecution.sol
├── src/interfaces/IAccount.sol
└── src/interfaces/IPerpsV2ExchangeRate.sol
    └── src/interfaces/IPyth.sol
```

## Deployment Addresses

#### Optimism

#### Optimism Goerli