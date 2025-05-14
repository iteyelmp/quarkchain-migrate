// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenConversion is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public erc20In;
    address public erc20Out;
    uint256 public startTime;
    uint256 public endTime;

    event TokenConverted(address account, uint256 amount);
    event ConversionPeriodUpdated(uint256 startTime, uint256 endTime);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _erc20In,
        address _erc20Out,
        uint256 _startTime,
        uint256 _endTime,
        address defaultAdmin
    ) public initializer {
        __AccessControl_init();
        __Pausable_init();

        require(
            _erc20In != address(0),
            "TokenConversion: invalid _erc20In token address"
        );
        require(
            _erc20Out != address(0),
            "TokenConversion: invalid _erc20Out token address"
        );
        require(
            _startTime < _endTime,
            "TokenConversion: start time must be before end time"
        );
        require(
            defaultAdmin != address(0),
            "TokenConversion: invalid default admin address"
        );

        erc20In = _erc20In;
        erc20Out = _erc20Out;
        startTime = _startTime;
        endTime = _endTime;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
    }

    /**
     * @notice Converts all `erc20In` tokens, the caller owns, to `erc20Out`
     * tokens. For all `erc20In` tokens that is burned the caller receives the
     * same amount of `erc20Out` tokens. The token conversion rate is 1:1.
     * @dev The caller must approve this contract to spend all their `erc20In`
     * tokens.
     */
    function convert() external whenNotPaused {
        address sender = _msgSender();

        require(
            block.timestamp >= startTime,
            "TokenConversion: conversion period has not started"
        );
        require(
            block.timestamp < endTime,
            "TokenConversion: conversion period has ended"
        );

        uint256 erc20InBalance = IERC20(erc20In).balanceOf(sender);
        require(erc20InBalance > 0, "TokenConversion: no tokens to convert");

        uint256 erc20OutBalance = IERC20(erc20Out).balanceOf(address(this));
        require(
            erc20OutBalance >= erc20InBalance,
            "TokenConversion: not enough tokens to convert"
        );

        uint256 allowance = IERC20(erc20In).allowance(sender, address(this));
        require(allowance >= erc20InBalance, "TokenConversion: insufficient allowance");

        // transfer and burn erc20In tokens
        IERC20(erc20In).safeTransferFrom(sender, address(this), erc20InBalance);
        IERC20(erc20In).safeTransfer(address(0), erc20InBalance); // pseudo-burn

        IERC20(erc20Out).safeTransfer(sender, erc20InBalance);

        emit TokenConverted(sender, erc20InBalance);
    }

    /**
     * @notice Sets the conversion period start and end times.
     * @dev Only the contract admin can call this function.
     * @param _startTime The new conversion period start time.
     * @param _endTime The new conversion period end time.
     */
    function setConversionPeriod(
        uint256 _startTime,
        uint256 _endTime
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _startTime < _endTime,
            "TokenConversion: start time must be before end time"
        );

        startTime = _startTime;
        endTime = _endTime;

        emit ConversionPeriodUpdated(_startTime, _endTime);
    }

    /**
     * @notice Drains all `erc20Out` tokens from the contract to the caller.
     * @dev Only the contract admin can call this function.
     */
    function drain() external onlyRole(DEFAULT_ADMIN_ROLE) {
        address sender = _msgSender();
        uint256 balance = IERC20(erc20Out).balanceOf(address(this));
        require(balance > 0, "TokenConversion: no tokens to drain");

        IERC20(erc20Out).safeTransfer(sender, balance);
    }

    /**
     * @notice Pauses the contract.
     * @dev Only the contract pauser can call this function.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses the contract.
     * @dev Only the contract pauser can call this function.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
