// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PensionVault} from "@/PensionVault.sol";
import {ERC20Mintable} from "../mocks/ERC20Mintable.sol";
import {MockStrategy} from "../mocks/MockStrategy.sol";
import {IERC20} from "@/interfaces/IERC20.sol";

contract PensionVaultTest is Test {
    //testcomment
    PensionVault public pensionVault;
    ERC20Mintable public pensionToken = new ERC20Mintable("PensionFi", "PFI");
    ERC20Mintable public usdc = new ERC20Mintable("USDC", "USDC");
    MockStrategy public mockStrategy;

    address abe = address(0xabe);
    address bec = address(0xbec);

    function setUp() public {
        startHoax(abe);
        pensionVault = new PensionVault(
            IERC20(address(pensionToken)),
            IERC20(address(usdc)),
            "PensionFiUsdc",
            "PFIUsdc",
            0,
            abe
        );
        console.log(pensionVault.owner());
        mockStrategy = new MockStrategy(address(pensionVault));
        pensionVault.whitelistStrategy(address(mockStrategy));
    }

    function test_deposit() public {
        uint amount = 100 ether; //fix and calc token decimals later
        usdc.mint(bec, amount);
        startHoax(bec);
        usdc.approve(address(pensionVault), amount);
        pensionVault.depositStrategy(amount, bec, 2629743, 86400 * 2, bec, 0);
    }

    function test_withdraw() public {}

    function test_payOut() public {}
}
