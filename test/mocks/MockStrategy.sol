// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strategy} from "../../src/strategies/Strategy.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";

contract MockStrategy is Strategy {
    constructor(
        address _yieldStrategyManager
    ) Strategy(_yieldStrategyManager) {}

    function deposit(
        address[] calldata,
        uint256[] calldata,
        bytes calldata,
        address
    ) external pure onlyYieldStrategyManager returns (bool) {
        return true;
    }

    function withdraw(
        address,
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        bytes calldata,
        address _to
    ) external onlyYieldStrategyManager returns (bool) {
        IERC20(_tokens[0]).transfer(_to, _amounts[0]);
        return true;
    }
}
