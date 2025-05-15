// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IStrategy} from "../interfaces/IStrategy.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

abstract contract Strategy is IStrategy {
    address internal immutable i_yieldStrategyManager;
    mapping(address => uint) beneficiaryAmts;
    modifier onlyYieldStrategyManager() {
        _;
    }

    constructor(address _yieldStrategyManager) {
        i_yieldStrategyManager = _yieldStrategyManager;
    }

    function getYieldStrategyManager() external view returns (address) {
        return i_yieldStrategyManager;
    }

    function deposit(
        address _by, //I suppose by could be beneficiary
        address token,
        uint256 amount,
        bytes calldata _additionalData
    ) public returns (bool) {
        require(msg.sender == i_yieldStrategyManager);
        SafeTransferLib.safeTransferFrom(
            token,
            i_yieldStrategyManager,
            address(this),
            amount
        );
    }

    function withdraw(
        address _by,
        address token,
        uint256 amount,
        bytes calldata _additionalData
    ) public returns (bool) {
        require(msg.sender == i_yieldStrategyManager);
        SafeTransferLib.safeTransferFrom(
            token,
            address(this),
            i_yieldStrategyManager,
            amount
        );
    }
}
