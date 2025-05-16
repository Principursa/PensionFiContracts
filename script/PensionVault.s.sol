// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PensionVault} from "@/PensionVault.sol";
import {MockStrategy} from "../test/mocks/MockStrategy.sol";
import {ERC20Mintable} from "../test/mocks/ERC20Mintable.sol";
import {IERC20} from "@/interfaces/IERC20.sol";

contract PensionVaultScript is Script {
    PensionVault pensionVault;
    MockStrategy mockStrategy;
    ERC20Mintable public pensionToken;
    ERC20Mintable public usdc;

    function setUp() public {
    }

    function getChainId() public view returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("Deployer address: ", deployerAddress);
        console.log("Deployer balance: ", deployerAddress.balance);
        console.log("BlockNumber: ", block.number);
        console.log("ChainId: ", getChainId());
        console.log("Deploying");
        vm.startBroadcast(deployerPrivateKey);
        pensionToken = new ERC20Mintable("PensionFi", "PFI");
        usdc = new ERC20Mintable("USDC", "USDC");
        pensionVault = new PensionVault(
            IERC20(address(pensionToken)),
            IERC20(address(usdc)),
            "PensionFiUsdc",
            "PFIUsdc",
            0,
            msg.sender
        );
        mockStrategy = new MockStrategy(address(pensionVault));
        pensionVault.whitelistStrategy(address(mockStrategy));
        vm.stopBroadcast();
    }
}
