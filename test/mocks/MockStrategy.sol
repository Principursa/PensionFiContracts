// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Strategy} from "../../src/strategies/Strategy.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";

contract MockStrategy is Strategy {
    constructor(
        address _yieldStrategyManager
    ) Strategy(_yieldStrategyManager) {}
}
