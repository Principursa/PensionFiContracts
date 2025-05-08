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


  //Yields would be the annuity? 
  //Maybe variable annuity
  //So deposit like 100,000k worth of stable coins throughout a period of time at fixed intervals(or maybe all at once) and get portion of yield
  //How much in annunities do you want to receive
  //For how long do you want to get it
  //This is how much you need to deposit 
  //Might need to figure how to calculate yield percentages on the smart contract itself 
  //function get_yield_percentage() public
  //address yieldBenefactor - allows people who pay into pensions to have it applicable to other people 
  //function harvestPension()
  //accumulationPhaseLength is the unix timestamp length of time of the period in which the plan is paid into
  //distributionPhaseLength is the unix timestamp length of time of the period in which the plan is paid out to the yieldBenefactor
  // preFixedTermInterval is the interval between payments into the plan
  // fixedTermInterval is the interval between payments to the yieldBenefactor
  // totalAmtToBeDeposited is the amount that needs to be deposited into the plan in order to fufill investment obligations 
  //maybe put in uint gracePeriod?
  //function createPensionPlan(uint accumulationPhaseLength, uint distributionPhaseLength, uint preFixedTermInterval,uint fixedTermInterval,address yieldBenefactor)
  //uint totalAmtToBeDeposited, address underlyingToken, 
  // maybe send minted shares to yieldBenefactor?
  //uint lastTermPaid  
  // preTermPeriod / preFixedTermInterval 
  //The frontend would handle the ux stuff related to calculating how much 
  //function payIntoPlan()
  //what kind of validation is necessary

}

