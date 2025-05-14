// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PensionVault} from "../../src/PensionVault.sol";

contract PensionVaultTest is Test {
    PensionVault public pensionvault;

    function setUp() public {
        pensionvault = new PensionVault;
    }

    function test_deposit() public {}

    function test_withdraw() public {}
}
