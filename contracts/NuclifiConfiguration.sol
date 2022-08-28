// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiConfiguration} from "./interfaces/INuclifiConfiguration.sol";

contract NuclifiConfiguration is
    INuclifiConfiguration,
    Ownable,
    ReentrancyGuard
{
    using Address for address;

    uint256 public constant override PERCENTAGE_PRECISION = 1e18;
    uint256 public override claimFeePercentage = 1e16;
    uint256 public override redeemFeePercentage = 1e16;
    uint256 public override purchaseFeePercentage = 1e16;

    mapping(uint256 => address) public override strategyFactoryAddress;

    function setStrategyFactoryAddress(
        uint256 strategyId_,
        address strategyFactoryAddress_
    ) external override nonReentrant onlyOwner {
        emit StrategyFactoryAddressChanged(
            strategyId_,
            strategyFactoryAddress[strategyId_],
            strategyFactoryAddress_
        );

        strategyFactoryAddress[strategyId_] = strategyFactoryAddress_;
    }

    function setClaimFeePercentage(uint256 claimFeePercentage_)
        external
        override
        nonReentrant
        onlyOwner
    {
        _requirePercentageNot100(claimFeePercentage_);

        emit ClaimFeePercentageChanged(
            claimFeePercentage,
            claimFeePercentage_
        );
        claimFeePercentage = claimFeePercentage_;
    }

    function setRedeemFeePercentage(uint256 redeemFeePercentage_)
        external
        override
        nonReentrant
        onlyOwner
    {
        _requirePercentageNot100(redeemFeePercentage_);

        emit RedeemFeePercentageChanged(
            redeemFeePercentage,
            redeemFeePercentage_
        );
        redeemFeePercentage = redeemFeePercentage_;
    }

    function setPurchaseFeePercentage(uint256 purchaseFeePercentage_)
        external
        override
        nonReentrant
        onlyOwner
    {
        _requirePercentageNot100(purchaseFeePercentage_);

        emit PurchaseFeePercentageChanged(
            purchaseFeePercentage_,
            purchaseFeePercentage_
        );
        purchaseFeePercentage = purchaseFeePercentage_;
    }

    function _requirePercentageNot100(uint256 percentage_) internal pure {
        require(
            percentage_ < PERCENTAGE_PRECISION,
            Errors.VALUE_MORE_THAN_MAXIMUM_PERMITTED
        );
    }
}
