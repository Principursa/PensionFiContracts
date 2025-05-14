// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IERC20} from "./IERC20.sol";

// As I'm combining the strategy contract with the vault contract I think some of these function signatures are redundant
interface IStrategy {
    function deposit(
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        bytes calldata _additionalData,
        address _for
    ) external returns (bool);

    function withdraw(
        address _by,
        address[] calldata _tokens,
        uint256[] calldata _amounts,
        bytes calldata _additionalData,
        address _to
    ) external returns (bool);

    function getYieldStrategyManager() external view returns (address);
}

//interface IBeefyStrategy {
//    function vault() external view returns (address);
//    function want() external view returns (IERC20);
//    function beforeDeposit() external;
//    function deposit() external;
//    function withdraw(uint256) external;
//    function balanceOf() external view returns (uint256);
//    function balanceOfWant() external view returns (uint256);
//    function balanceOfPool() external view returns (uint256);
//    function harvest() external;
//    function retireStrat() external;
//    function panic() external;
//    function pause() external;
//    function unpause() external;
//    function paused() external view returns (bool);
//    function owner() external view returns (address);
//    function keeper() external view returns (address);
//    function setKeeper(address) external;
//    function unirouter() external view returns (address);
//    function beefyFeeRecipient() external view returns (address);
//    function setBeefyFeeRecipient(address) external;
//    function strategist() external view returns (address);
//    function setStrategist(address) external;
//}
