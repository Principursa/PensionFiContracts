// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PensionVault} from "@/PensionVault.sol";
import {ERC20Mintable} from "../mocks/ERC20Mintable.sol";
import {MockStrategy} from "../mocks/MockStrategy.sol";
import {IERC20} from "@/interfaces/IERC20.sol";

contract PensionVaultTest is Test {
    PensionVault public pensionvault;
    ERC20Mintable public pensionToken = new ERC20Mintable("PensionFi","PFI");
    ERC20Mintable public usdc = new ERC20Mintable("USDC","USDC");

    address abe = address(0xabe);
    address bec = address(0xbec);

    function setUp() public {
      startHoax(abe);
      pensionvault = new PensionVault(
        IERC20(address(pensionToken)), 
        IERC20(address(usdc)),
        "PensionFiUsdc",
        "PFIUsdc",
        0,
        msg.sender);
    }

    function test_deposit() public {}

    function test_withdraw() public {}

    function test_payOut() public {}
}
