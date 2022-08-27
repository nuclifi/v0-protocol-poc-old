// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiConfiguration} from "./interfaces/INuclifiConfiguration.sol";

contract NuclifiConfiguration is INuclifiConfiguration, Ownable {
    using Address for address;

    uint256 public constant override PERCENTAGE_PRECISION = 1e18;

    uint256 public override claimFeePercentage = 1e16;
    uint256 public override redeemFeePercentage = 1e16;
    uint256 public override purchaseFeePercentage = 1e16;

    mapping(uint256 => address) public override strategyFactoryAddress;

    function setStrategyFactoryAddress(
        uint256 strategyId_,
        address strategyFactoryAddress_
    ) external override onlyOwner {
        emit StrategyFactoryAddressChanged(
            strategyId_,
            strategyFactoryAddress[strategyId_],
            strategyFactoryAddress_
        );
        strategyFactoryAddress[strategyId_] = strategyFactoryAddress_;
    }
}
