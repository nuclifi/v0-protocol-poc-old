// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface INuclifiConfiguration {
    // solhint-disable-next-line
    function PERCENTAGE_PRECISION()
        external
        view
        returns (
            // solhint-disable-next-line
            uint256 PERCENTAGE_PRECISION_
        );

    function claimFeePercentage()
        external
        view
        returns (uint256 claimFeePercentage_);

    function redeemFeePercentage()
        external
        view
        returns (uint256 redeemFeePercentage_);

    function purchaseFeePercentage()
        external
        view
        returns (uint256 purchaseFeePercentage_);

    function strategyFactoryAddress(uint256 strategyId_)
        external
        view
        returns (address strategyFactoryAddress_);

    function setStrategyFactoryAddress(
        uint256 strategyId_,
        address strategyFactoryAddress_
    ) external;

    event StrategyFactoryAddressChanged(
        uint256 indexed strategyId_,
        address oldAddress_,
        address newAddress_
    );
}
