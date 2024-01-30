// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./MultisigWallet.sol";

contract FactoryMultisigWallet is Ownable2Step {
    address[] public wallets;

    event NewMultiSig(address indexed wallet, address indexed owner);

    /**
     * @dev Creates a new multisig wallet
     * @param _walletOwners List of wallet owners
     * @param _threshold Number of required confirmations
     */
    function createMultiSigWallet(
        address[] memory _walletOwners,
        uint256 _threshold
    ) public returns (address) {
        MultisigWallet wallet = new MultisigWallet(_walletOwners, _threshold);
        wallets.push(address(wallet));
        emit NewMultiSig(address(wallet), msg.sender);
        return address(wallet);
    }
}
