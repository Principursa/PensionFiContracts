// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IAaveToken {
    function POOL() external view returns (address);
    function getIncentivesController() external view returns (address);
}
