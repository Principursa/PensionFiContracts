// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "solady/tokens/ERC4626.sol";
import {IERC20} from "@/interfaces/IERC20.sol";
import {IYieldStrategyManager} from "@/interfaces/IYieldStrategyManager.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/utils/structs/EnumerableSet.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IStrategy} from "@/interfaces/IStrategy.sol";

contract PensionVault is ERC4626, IYieldStrategyManager, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    EnumerableSet.AddressSet private s_whitelistedStrategies;

    mapping(address user => mapping(address strategy => address operator))
        private s_operators;

    IERC20 public pensionToken;
    IERC20 public underlyingStable;
    uint public gracePeriod;
    string private _name;
    string private _symbol;
    uint public exitTax; //If necessary
    struct Plan {
        uint startTime;
        uint gracePeriod;
        uint accumulationPhaseLength;
        uint distributionPhaseLength;
        uint accumulationPhaseInterval;
        uint distributionPhaseInterval;
        address beneficiary;
        uint totalDepositAmount; //both this var and curdepositamount are a little weird when considering distrib phase
        uint currentDepositAmount;
        address benefactor;
        bool accumOrDistribPhase;
        uint payoutsClaimed;
        uint strategyId;
    }

    mapping(address => mapping(address => Plan)) Plans;

    constructor(
        IERC20 _pensionToken,
        IERC20 _underlyingStable,
        string memory __name,
        string memory __symbol,
        uint _exitTax,
        address _owner
    ) Ownable(_owner) {
        pensionToken = _pensionToken;
        underlyingStable = _underlyingStable;
        _name = __name;
        _symbol = __symbol;
        exitTax = _exitTax;
    }

    function asset() public view override returns (address) {
        return address(underlyingStable);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                YieldStrategyManager functions              */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function getStrategy(uint256 _index) public view returns (address) {
        return s_whitelistedStrategies.at(_index);
    }

    function whitelistStrategy(address _strategy) external onlyOwner {
        require(_strategy != address(0), "address is zero");
        s_whitelistedStrategies.add(_strategy);
    }

    function removeStrategy(address _strategy) external onlyOwner {
        //require whitelistedstrategy

        s_whitelistedStrategies.remove(_strategy);

        emit RemovedStrategyFromWhitelist(_strategy);
    }

    function setOperator(
        address _strategy,
        address _operator,
        bool _setOperator
    ) external {
        // require whitelistedstrategy
        require(_strategy != address(0), "address is zero");
        if (_setOperator) s_operators[msg.sender][_strategy] = _operator;
        else delete s_operators[msg.sender][_strategy];

        emit OperatorSet(msg.sender, _strategy, _operator, _setOperator);
    }

    function _requireWhiteListedStrategy(address _strategy) internal view {
        if (!s_whitelistedStrategies.contains(_strategy)) {
            revert("Strategy is not whitelisted");
        }
    }

    function getAllStrategies() external view returns (address[] memory) {
        return s_whitelistedStrategies.values();
    }

    function getOperator(
        address _strategy,
        address _user
    ) external view returns (address) {
        return s_operators[_user][_strategy];
    }

    //function deposit(
    //    address _strategy,
    //    address[] calldata _tokens,
    //    uint256[] calldata _amounts,
    //    bytes calldata _additionalData,
    //    address _onBehalfOf
    //) external;

    //function withdraw(
    //    address _user,
    //    address _strategy,
    //    address[] calldata _tokens,
    //    uint256[] calldata _amounts,
    //    bytes calldata _additionalData,
    //    address _to
    //) external;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                 Pension-Vault functions                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function createPensionPlan(
        uint accumulationPhaseLength,
        uint distributionPhaseLength,
        uint accumulationPhaseInterval,
        uint distributionPhaseInterval,
        address beneficiary,
        uint totalDepositAmount,
        address benefactor,
        uint strategyId
    ) private {
        Plan memory newPlan;
        newPlan.startTime = block.timestamp;
        newPlan.gracePeriod = gracePeriod;
        newPlan.accumulationPhaseLength;
        newPlan.distributionPhaseLength = distributionPhaseLength;
        newPlan.accumulationPhaseInterval = accumulationPhaseInterval;
        newPlan.distributionPhaseInterval = distributionPhaseInterval;
        newPlan.beneficiary = beneficiary;
        newPlan.totalDepositAmount = totalDepositAmount;
        newPlan.currentDepositAmount = 0;
        newPlan.benefactor = benefactor;
        newPlan.accumOrDistribPhase = false;
        newPlan.payoutsClaimed = 0;
        newPlan.strategyId = strategyId;
        Plans[benefactor][beneficiary] = newPlan;
    }

    //This function is a little redundant for the purposes for this hackathon

    function payIntoPlan(address beneficiary) private {
        Plan memory selectedPlan = Plans[msg.sender][beneficiary];
        require(selectedPlan.beneficiary != address(0)); //implement validation here to ensure that a plan exists
        require(
            selectedPlan.currentDepositAmount < selectedPlan.totalDepositAmount
        );
    }

    //Actually maybe function here that determines if plan is in accum or distrib phase so I dont' have to bother with state
    function isAccumulativePhase(Plan memory givenPlan) public pure returns (bool) {
        return false;
    }

    function payOutPlan(address beneficiary) public {
        Plan memory selectedPlan = Plans[msg.sender][beneficiary];
        require(selectedPlan.beneficiary != address(0), "plan does not exist"); // existence validation again
        require(
            selectedPlan.currentDepositAmount ==
                selectedPlan.totalDepositAmount,
            "plan is not payed off yet"
        );
        require(
            !isAccumulativePhase(selectedPlan),
            "Plan is still in accumulative phase"
        );
        uint startTime = selectedPlan.startTime;
        //change the above to distribstarttime later, since startTime is declared when funds are deposited it's alright for now
        uint distributionPhaseLength = selectedPlan.distributionPhaseLength;
        uint totalDepositAmount = selectedPlan.totalDepositAmount;
        uint distributionPhaseInterval = selectedPlan.distributionPhaseInterval;
        uint totalPayouts = distributionPhaseLength / distributionPhaseInterval;
        uint individualPayoutAmounts = totalDepositAmount / totalPayouts;
        uint timeElapsedDistrib = block.timestamp - startTime;
        uint payoutsDue = timeElapsedDistrib / distributionPhaseInterval;
        require(payoutsDue <= totalPayouts, "Too many payouts");
        uint alreadyClaimed = selectedPlan.payoutsClaimed;
        require(payoutsDue > alreadyClaimed, "No payouts available");
        uint pendingPayouts = payoutsDue - alreadyClaimed;
        uint payoutAmount = (individualPayoutAmounts) * pendingPayouts;
        selectedPlan.payoutsClaimed = payoutsDue;
        IStrategy strat = IStrategy(getStrategy(selectedPlan.strategyId));
        strat.withdraw(beneficiary, asset(), payoutAmount, bytes(""));
        SafeTransferLib.safeTransfer(asset(), beneficiary, payoutAmount);
    }

    //function calculateReturnOut(Plan memory givenPlan) public {
    //}

    function viewTermInfo(
        address benefactor,
        address beneficiary
    ) external view returns (Plan memory) {
        Plan memory givenPlan = Plans[benefactor][beneficiary];
        return givenPlan;
    }

    function depositStrategy(
        uint256 assets,
        address to,
        uint distributionPhaseLength,
        uint distributionPhaseInterval,
        address beneficiary,
        uint strategyId
    ) public returns (uint256 shares) {
        require(
            assets < maxDeposit(address(this)),
            "Deposit is greater than assets"
        );
        shares = previewDeposit(assets);
        deposit(assets, to);
        createPensionPlan(
            0,
            distributionPhaseLength,
            0,
            distributionPhaseInterval,
            beneficiary,
            assets,
            msg.sender,
            strategyId
        );
        _afterDepositStrategy(assets, strategyId, beneficiary);
        Plans[msg.sender][beneficiary].currentDepositAmount = assets;
    }

    function deposit(
        uint256 assets,
        address to
    ) public override returns (uint256 shares) {
        //visibility is going to be an issue later on, for now it's alright tho
        require(
            assets < maxDeposit(address(this)),
            "Deposit is greater than assets"
        );
        shares = previewDeposit(assets);
        _deposit(msg.sender, to, assets, shares);
    }

    function _afterDepositStrategy(
        uint256 assets,
        uint256 strategyId,
        address beneficiary
    ) internal {
        SafeTransferLib.safeApprove(asset(), getStrategy(strategyId), assets);
        IStrategy strat = IStrategy(getStrategy(strategyId));
        strat.deposit(beneficiary, asset(), assets, bytes(""));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  Frontend Helper functions                 */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    function getDistributionLengthRemaining(
        address benefactor, address beneficiary
    ) external view returns (uint) {
        Plan memory selectedPlan = Plans[benefactor][beneficiary];
        require(selectedPlan.startTime != 0, "Plan does not exist");
        uint timeElapsedSinceStart = block.timestamp - selectedPlan.startTime;
        uint distributionLengthRemaining = selectedPlan
            .distributionPhaseLength - timeElapsedSinceStart;
        return distributionLengthRemaining;
    }

    function getAmountPerDistribInterval(
        address benefactor, address beneficiary
    ) external view returns (uint) {
        Plan memory selectedPlan = Plans[benefactor][beneficiary];
        require(selectedPlan.startTime != 0, "Plan does not exist");
        uint distributionPhaseLength = selectedPlan.distributionPhaseLength;
        uint totalDepositAmount = selectedPlan.totalDepositAmount;
        uint distributionPhaseInterval = selectedPlan.distributionPhaseInterval;
        uint totalPayouts = distributionPhaseLength / distributionPhaseInterval;
        uint individualPayoutAmounts = totalDepositAmount / totalPayouts;
        return individualPayoutAmounts;
    }
}
