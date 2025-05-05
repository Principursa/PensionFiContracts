// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IStrategyFactory {
  function createStrategy(string calldata _strategyName) external returns (address);
  function native() external view returns (address);
  function keeper() external view returns (address);
  function FeeRecipient() external view returns (address);
  function feeConfig() external view returns (address);
  function globalPause() external view returns (bool);
  function strategyPause(string calldata stratName) external view returns (bool);

}
