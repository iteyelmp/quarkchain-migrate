// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin-upgradeable/contracts/utils/PausableUpgradeable.sol";
import "@openzeppelin-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./IOptimismPortal2.sol";

contract TokenConversion is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable
{
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public erc20In;
    address public optimismPortal2;
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
        address _optimismPortal2,
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
            _optimismPortal2 != address(0),
            "TokenConversion: invalid _optimismPortal2 address"
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
        optimismPortal2 = _optimismPortal2;
        startTime = _startTime;
        endTime = _endTime;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
    }

    /**
     * @notice Converts all `erc20` tokens, the caller owns, to `l2 erc20`
     * tokens. For all `erc20` tokens that is burned the caller receives the
     * same amount of `l2 erc20` tokens. The token conversion rate is 1:1.
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
        uint256 allowance = IERC20(erc20In).allowance(sender, address(this));
        require(allowance >= erc20InBalance, "TokenConversion: insufficient allowance");

        // transfer and burn erc20In tokens
        IERC20(erc20In).safeTransferFrom(sender, address(this), erc20InBalance);
        // Do NOT send tokens to address(0).
        // Many ERC20 implementations treat address(0) as an invalid receiver
        // and will revert the transaction to prevent misuse or accidental loss.
        //
        // Instead, use the "dead" address (0x000...dEaD) which is a known burn address
        // with no private key and is used for pseudo-burning tokens.
        //  TODO
        //  IERC20(erc20In).safeTransfer(0x000000000000000000000000000000000000dEaD, erc20InBalance);
        //  TODO
        //  IERC20(erc20In).safeTransferFrom(sender, 0x000000000000000000000000000000000000dEaD, erc20InBalance);

        // mint l2 token
        IOptimismPortal2(optimismPortal2).mintTransaction(sender, erc20InBalance);

        emit TokenConverted(sender, erc20InBalance);
    }

    /**
     * @notice Drains all `erc20Out` tokens from the contract to the caller.
     * @dev Only the contract admin can call this function.
     */
    function drain() external onlyRole(DEFAULT_ADMIN_ROLE) {
        address sender = _msgSender();
        uint256 balance = IERC20(erc20In).balanceOf(address(this));
        require(balance > 0, "TokenConversion: no tokens to drain");

        IERC20(erc20In).safeTransfer(sender, balance);
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
