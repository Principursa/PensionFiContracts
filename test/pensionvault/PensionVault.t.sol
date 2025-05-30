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
    uint dayUnix = 86400;
    uint monthUnix = 2629743;
    uint distributionPhaseLength = monthUnix;
    uint distributionPhaseInterval = dayUnix * 2;
    struct Plan {
        uint startTime;
        uint gracePeriod;
        uint accumulationPhaseLength;
        uint distributionPhaseLength;
        uint accumulationPhaseInterval;
        uint distributionPhaseInterval;
        address beneficiary;
        uint totalDepositAmount;
        uint currentDepositAmount;
        address benefactor;
        bool accumOrDistribPhase;
        uint payoutsClaimed;
        uint strategyId;
    }

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

    function deposit() private {
        uint amount = 100 ether; //fix and calc token decimals later
        usdc.mint(bec, amount);
        startHoax(bec);
        usdc.approve(address(pensionVault), amount);
        pensionVault.depositStrategy(
            amount,
            bec,
            distributionPhaseLength,
            distributionPhaseInterval,
            bec,
            0
        );
    }

    function test_deposit() public {
        deposit();
        console.log(pensionVault.balanceOf(bec));
        console.log(usdc.balanceOf(bec));
        assertLt(0, pensionVault.balanceOf(bec));
        assertGt(usdc.balanceOf(address(mockStrategy)), 0);
    }

    function test_payOutFails() public {
        deposit();
        vm.expectRevert();
        pensionVault.payOutPlan(bec);
    }

    function test_payOutSucceeds() public {
        uint256 start = block.timestamp;
        deposit();
        uint beforeBalance = usdc.balanceOf(bec);
        vm.warp(start + 2 days);
        pensionVault.payOutPlan(bec);
        uint currentBalance = usdc.balanceOf(bec);
        console.log(currentBalance);
        assertGt(currentBalance, beforeBalance);
    }

    function test_viewTermInfo() public {
        deposit();
        PensionVault.Plan memory plan = pensionVault.viewTermInfo(bec, bec);
        console.log(plan.beneficiary);
    }

    function test_getDistributionLengthRemaining() public {
        deposit();
        uint dlr = pensionVault.getDistributionLengthRemaining(bec,bec);
        console.log("DLR");
        console.log(dlr);
    }

    function test_getamountPerDistribInterval() public {
        deposit();
        uint adi = pensionVault.getAmountPerDistribInterval(bec,bec);
        console.log("ADI");
        console.log(adi);
    }
}
