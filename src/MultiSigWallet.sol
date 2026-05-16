// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Multi-Signature Wallet (Hardened)
/// @notice Backward-compatible upgrade of your original contract

// ✅ FIX 1: Validate `required` in constructor to prevent invalid state

contract MultiSigWallet {

    error NotOwner();
    error TxDoesNotExist();
    error AlreadyExecuted();
    error AlreadyConfirmed();
    error NotConfirmed();
    error NotEnoughConfirmations();
    error InvalidOwners();
    error InvalidRequirement();
    error TxFailed();

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);

    // ================= STATE =================
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;

    mapping(uint => mapping(address => bool)) public isConfirmed;

    // ================= MODIFIERS =================
    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    modifier txExists(uint _txIndex) {
        if (_txIndex >= transactions.length) revert TxDoesNotExist();
        _;
    }

    modifier notExecuted(uint _txIndex) {
        if (transactions[_txIndex].executed) revert AlreadyExecuted();
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        if (isConfirmed[_txIndex][msg.sender]) revert AlreadyConfirmed();
        _;
    }

    // ================= CONSTRUCTOR =================
    constructor(address[] memory _owners, uint _required) {
        uint ownersLength = _owners.length;

        if (ownersLength == 0) revert InvalidOwners();

        // ✅ FIX 1: required must be valid
        if (_required == 0 || _required > ownersLength) {
            revert InvalidRequirement();
        }

        for (uint i = 0; i < ownersLength; i++) {
            address owner = _owners[i];

            if (owner == address(0) || isOwner[owner]) {
                revert InvalidOwners();
            }

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    // ================= RECEIVE =================
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // ================= CORE LOGIC =================

    function submitTransaction(address to, uint value, bytes calldata data)
        external
        onlyOwner
    {
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to: to,
            value: value,
            data: data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, to, value, data);
    }

    function confirmTransaction(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        isConfirmed[_txIndex][msg.sender] = true;
        transactions[_txIndex].numConfirmations += 1;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        if (!isConfirmed[_txIndex][msg.sender]) revert NotConfirmed();

        isConfirmed[_txIndex][msg.sender] = false;

        // prevent underflow safety (Solidity 0.8 safe but explicit logic helps clarity)
        transactions[_txIndex].numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage txn = transactions[_txIndex];

        if (txn.numConfirmations < required) {
            revert NotEnoughConfirmations();
        }

        // mark BEFORE external call (reentrancy-safe pattern)
        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);

        if (!success) {
            revert TxFailed();
        }

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // ================= VIEW FUNCTIONS =================

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        external
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage txn = transactions[_txIndex];

        return (
            txn.to,
            txn.value,
            txn.data,
            txn.executed,
            txn.numConfirmations
        );
    }
}