
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PensionVault} from "@/PensionVault.sol";
import {MockStrategy} from "../test/mocks/MockStrategy.sol";
import {ERC20Mintable} from "../test/mocks/ERC20Mintable.sol";

contract PensionVaultScript is Script {
  function setUp() public {

  }

  function getChainId() public view returns(uint256) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    return chainId;
  }
  function run() external{
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployerAddress = vm.addr(deployerPrivateKey);
    console.log("Deployer address: ", deployerAddress);
    console.log("Deployer balance: ", deployerAddress.balance);
    console.log("BlockNumber: ", block.number);
    console.log("ChainId: ", getChainId());
    console.log("Deploying");

    vm.startBroadcast(deployerPrivateKey);
    vm.stopBroadcast();
    

  }

}
