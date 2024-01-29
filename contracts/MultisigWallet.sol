// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultisigWallet {
    event Deposit(address indexed sender, uint amount, uint balance);

    event SubmitTransaction(
        string txType,
        uint indexed txIndex,
        address indexed owner,
        uint numConfirmations
    );

    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    address[] public walletOwners;
    uint256 public threshold;
    mapping(address => bool) public isOwner;
    address firstOwner;

    mapping(uint => mapping(address => bool)) public isConfirmed;

    struct TransactionType {
        string txType;
        bool executed;
        uint256 numConfirmations;
        uint256 amount;
    }

    TransactionType[] public transactions;

    /**
     * @dev Modifier that checks if the sender is a group owner
     */
    modifier onlyWalletOwner() {
        require(
            isOwner[msg.sender],
            "Only group owners can call this function"
        );
        _;
    }

    /**
     * @dev Modifier that checks if a transaction exists
     * @param _txIndex Index of the transaction
     */
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }

    /**
     * @dev Modifier that checks if a transaction has not been executed
     * @param _txIndex Index of the transaction
     */
    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    /**
     * @dev Modifier that checks if a transaction has not been confirmed by the owner
     * @param _txIndex Index of the transaction
     */
    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    /**
     * @dev Constructor
     * @param _walletOwners List of addresses of group owners
     * @param _threshold Number of signatures required to execute a transaction
     */
    constructor(address[] memory _walletOwners, uint256 _threshold) {
        require(
            _threshold <= _walletOwners.length,
            "Threshold cannot be greater than the number of wallet owners"
        );

        require(
            _threshold >= 0 && threshold <= _walletOwners.length,
            "Invalid threshold"
        );

        require(
            _walletOwners.length > 0,
            "wallet must have at least one owner"
        );

        for (uint256 i = 0; i < _walletOwners.length; i++) {
            address walletOwner = _walletOwners[i];
            require(
                walletOwner != address(0),
                "Wallet owner address cannot be the zero address"
            );
            require(
                !isOwner[walletOwner],
                "Wallet owner address cannot be duplicated"
            );
            isOwner[walletOwner] = true;
            walletOwners.push(payable(walletOwner));
        }

        threshold = _threshold;
        firstOwner = msg.sender;
    }

    /**
     * @dev Fallback function to receive ETH
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
     * @dev function to deposit funds into the contract
     */
    function deposit() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    /**
        @dev Submit a transaction to the contract
        @param _txType Type of transaction
        @param _amount Amount of the transaction
     */
    function submitTransaction(
        string memory _txType,
        uint256 _amount
    ) public onlyWalletOwner {
        uint256 txIndex = transactions.length;

        transactions.push(
            TransactionType({
                txType: _txType,
                executed: false,
                numConfirmations: 0,
                amount: _amount
            })
        );

        emit SubmitTransaction(_txType, txIndex, msg.sender, 0);
    }

    /**
     * @dev Confirm a transaction
     * @param _txIndex Index of the transaction
     */
    function confirmTransaction(
        uint256 _txIndex
    )
        public
        onlyWalletOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        TransactionType storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);

        if (transaction.numConfirmations >= threshold) {
            withdraw(transaction.amount);
        }
    }

    /**
     * @dev function to withdraw funds from the contract
     * @param _amount Amount to withdraw
     */
    function withdraw(uint256 _amount) private onlyWalletOwner {
        require(
            address(this).balance >= _amount,
            "Insufficient funds in contract"
        );
        payable(msg.sender).transfer(_amount);
    }

    /**
     * @dev function to revoke a confirmation for a transaction
     * @param _txIndex Index of the transaction to revoke confirmation for
     */

    function revokeConfirmation(
        uint256 _txIndex
    ) public onlyWalletOwner txExists(_txIndex) notExecuted(_txIndex) {
        TransactionType storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }
}
