// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

library PensionVault {
    struct Plan {
        uint256 startTime;
        uint256 gracePeriod;
        uint256 accumulationPhaseLength;
        uint256 distributionPhaseLength;
        uint256 accumulationPhaseInterval;
        uint256 distributionPhaseInterval;
        address beneficiary;
        uint256 totalDepositAmount;
        uint256 currentDepositAmount;
        address benefactor;
        bool accumOrDistribPhase;
        uint256 payoutsClaimed;
        uint256 strategyId;
    }
}

interface IPensionVault {
    error AllowanceOverflow();
    error AllowanceUnderflow();
    error DepositMoreThanMax();
    error InsufficientAllowance();
    error InsufficientBalance();
    error InvalidPermit();
    error MintMoreThanMax();
    error OwnableInvalidOwner(address owner);
    error OwnableUnauthorizedAccount(address account);
    error Permit2AllowanceIsFixedAtInfinity();
    error PermitExpired();
    error RedeemMoreThanMax();
    error TotalSupplyOverflow();
    error WithdrawMoreThanMax();
    error YieldStrategyManager__FailedToDepositIntoStrategy();
    error YieldStrategyManager__FailedToWithdrawFromStrategy();
    error YieldStrategyManager__NotUserOrOperator();
    error YieldStrategyManager__NotWhitelistedStrategy(address strategy);

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Deposit(address indexed by, address indexed owner, uint256 assets, uint256 shares);
    event DepositedIntoStrategy(
        address by,
        address indexed strategy,
        address[] indexed tokens,
        uint256[] amounts,
        bytes additionalData,
        address indexed onBehalfOf
    );
    event OperatorSet(address indexed user, address indexed strategy, address indexed operator, bool setOperator);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RemovedStrategyFromWhitelist(address indexed strategy);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event WhitelistedStrategy(address indexed strategy);
    event Withdraw(address indexed by, address indexed to, address indexed owner, uint256 assets, uint256 shares);
    event WithdrawnFromStrategy(
        address indexed by,
        address indexed strategy,
        address[] indexed tokens,
        uint256[] amounts,
        bytes additionalData,
        address to
    );

    function DOMAIN_SEPARATOR() external view returns (bytes32 result);
    function allowance(address owner, address spender) external view returns (uint256 result);
    function approve(address spender, uint256 amount) external returns (bool);
    function asset() external view returns (address);
    function balanceOf(address owner) external view returns (uint256 result);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function decimals() external view returns (uint8);
    function deposit(uint256 assets, address to) external returns (uint256 shares);
    function depositStrategy(
        uint256 assets,
        address to,
        uint256 distributionPhaseLength,
        uint256 distributionPhaseInterval,
        address beneficiary,
        uint256 strategyId
    ) external returns (uint256 shares);
    function exitTax() external view returns (uint256);
    function getAllStrategies() external view returns (address[] memory);
    function getAmountPerDistribInterval(address beneficiary) external view returns (uint256);
    function getDistributionLengthRemaining(address beneficiary) external view returns (uint256);
    function getOperator(address _strategy, address _user) external view returns (address);
    function getStrategy(uint256 _index) external view returns (address);
    function gracePeriod() external view returns (uint256);
    function isAccumulativePhase(PensionVault.Plan memory givenPlan) external returns (bool);
    function maxDeposit(address to) external view returns (uint256 maxAssets);
    function maxMint(address to) external view returns (uint256 maxShares);
    function maxRedeem(address owner) external view returns (uint256 maxShares);
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);
    function mint(uint256 shares, address to) external returns (uint256 assets);
    function name() external view returns (string memory);
    function nonces(address owner) external view returns (uint256 result);
    function owner() external view returns (address);
    function payOutPlan(address beneficiary) external;
    function pensionToken() external view returns (address);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    function previewMint(uint256 shares) external view returns (uint256 assets);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);
    function redeem(uint256 shares, address to, address owner) external returns (uint256 assets);
    function removeStrategy(address _strategy) external;
    function renounceOwnership() external;
    function setOperator(address _strategy, address _operator, bool _setOperator) external;
    function symbol() external view returns (string memory);
    function totalAssets() external view returns (uint256 assets);
    function totalSupply() external view returns (uint256 result);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external;
    function underlyingStable() external view returns (address);
    function viewTermInfo(address benefactor, address beneficiary) external returns (PensionVault.Plan memory);
    function whitelistStrategy(address _strategy) external;
    function withdraw(uint256 assets, address to, address owner) external returns (uint256 shares);
}
