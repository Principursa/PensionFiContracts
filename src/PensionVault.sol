// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "solady/tokens/ERC4626.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract PensionVault is ERC4626 {
  IERC20 public pensionToken;
  IERC20 public underlyingStable;
  string private _name;
  string private _symbol;

  constructor(IERC20 _pensionToken, IERC20 _underlyingStable, string memory __name, string memory __symbol){
    pensionToken = _pensionToken;
    underlyingStable = _underlyingStable;
    _name = __name;
    _symbol = __symbol;
  }
 

  function asset() public view override returns (address){
    return address(underlyingStable);

  }
  function name() public view override returns (string memory){
    return _name;

  }
  function symbol() public view override returns (string memory) {
    return _symbol;

  }


}

