// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface INuclifiStrategyFactory {
    function deployStrategy() external returns (address strategy_);

    event StrategyDeployed(address strategy_);
}
