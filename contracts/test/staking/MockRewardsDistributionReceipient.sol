// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Errors} from "../../libraries/Errors.sol";

abstract contract MockRewardsDistributionReceipient {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) external virtual;

    modifier onlyRewardsDistribution() {
        require(
            msg.sender == rewardsDistribution,
            Errors.SENDER_NOT_AUTHORIZED
        );
        _;
    }
}
