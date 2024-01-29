# <p align="center">MultiSig Wallet</p>

Every time you execute **_createMultiSigWallet_** it will create a new multisig wallet (deploy new contract)

- Params for **_createMultiSigWallet_** : 1. array of addresses (EOA) , 2. threshold(no of signatures required to execute a transaction)

## Contracts

- `FactoryMultisigWallet` - use this contract to create new multisig wallets using `createMultiSigWallet` function
- `MultisigWallet` contract contains all the functionalities required for a multisig wallet
- Feature 3

## 🛠️ Tech Stack

- [Solidity](https://https://soliditylang.org/)
- [Hardhat](https://hardhat.org/)
