
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract DeployMultiSig is Script {
    function run() external returns (MultiSigWallet) {

        // ================= OWNERS =================
        address[] memory owners = new address[](3);

        owners[0] = 0xaA7827FF19A96231f6582A830f3df8ea8aF4cfB9; // tsion
        owners[1] = 0x6c856fc3768Bb3715015c949273eA2CE6B1ad4BE; // salah
        owners[2] = 0x255e59557Ccd5bEFb82e2c5F72E61768713a8a74; // lina

        // ================= THRESHOLD =================
        uint256 requiredConfirmations = owners.length - 1; 

        // 🧠 Safety check (prevents broken multisig deployment)
        require(
            requiredConfirmations > 0 && requiredConfirmations <= owners.length,
            "Invalid requirement"
        );

        vm.startBroadcast();

        MultiSigWallet wallet = new MultiSigWallet(
            owners,
            requiredConfirmations
        );

        vm.stopBroadcast();

        // ================= LOG =================
        console.log("MultiSigWallet deployed at:", address(wallet));

        return wallet;
    }
}