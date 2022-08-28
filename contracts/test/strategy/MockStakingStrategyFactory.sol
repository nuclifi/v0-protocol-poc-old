// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "../../libraries/Errors.sol";
import {MockStakingStrategy} from "./MockStakingStrategy.sol";
import {INuclifiCertificate} from "../../interfaces/INuclifiCertificate.sol";

contract MockStakingStrategyFactory is Ownable, ReentrancyGuard {
    using Address for address;

    address public controller;
    address public stakingProgram;
    address public nuclifiCertificate;

    function setAddresses(
        address controller_,
        address stakingProgram_,
        address nuclifiCertificate_
    ) external onlyOwner {
        controller = controller_;
        stakingProgram = stakingProgram_;
        nuclifiCertificate = nuclifiCertificate_;
    }

    function generate(uint256 tokenId) external returns (address) {
        require(msg.sender == controller, "Invalid");

        address strategy = address(
            new MockStakingStrategy(
                controller,
                stakingProgram,
                nuclifiCertificate
            )
        );

        MockStakingStrategy(strategy).setCertificateId(tokenId);

        return strategy;
    }
}
