// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "../../libraries/Errors.sol";
import {MockStakingStrategy} from "./MockStakingStrategy.sol";
import {INuclifiStrategy} from "../../interfaces/INuclifiStrategy.sol";
import {INuclifiCertificate} from "../../interfaces/INuclifiCertificate.sol";
import {INuclifiStrategyFactory} from "../../interfaces/INuclifiStrategyFactory.sol";

contract MockStakingStrategyFactory is
    INuclifiStrategyFactory,
    Ownable,
    ReentrancyGuard
{
    using Address for address;

    address public stakingProgramAddress;
    address public nuclifiControllerAddress;
    address public nuclifiCertificateAddress;

    event StakingProgramAddressChanged(address stakingProgram_);
    event NuclifiControllerAddressChanged(address nuclifiControllerAddress_);
    event NuclifiCertificateAddressChanged(address nuclifiCertificateAddress_);

    function setAddresses(
        address stakingProgramAddress_,
        address nuclifiControllerAddress_,
        address nuclifiCertificateAddress_
    ) external nonReentrant onlyOwner {
        require(
            stakingProgramAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );
        require(
            nuclifiControllerAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );
        require(
            nuclifiCertificateAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );

        emit StakingProgramAddressChanged(stakingProgramAddress_);
        stakingProgramAddress = stakingProgramAddress_;

        emit NuclifiControllerAddressChanged(nuclifiControllerAddress_);
        nuclifiControllerAddress = nuclifiControllerAddress;

        emit NuclifiCertificateAddressChanged(nuclifiCertificateAddress_);
        nuclifiCertificateAddress = nuclifiCertificateAddress_;

        renounceOwnership();
    }

    function deployStrategy()
        external
        override
        nonReentrant
        returns (address)
    {
        requireCallerIsNuclifiControllerAddress();

        INuclifiStrategy strategy = INuclifiStrategy(
            new MockStakingStrategy(
                stakingProgramAddress,
                nuclifiControllerAddress,
                nuclifiCertificateAddress
            )
        );

        return address(strategy);
    }

    function requireCallerIsNuclifiControllerAddress() internal view {
        require(
            _msgSender() == nuclifiControllerAddress,
            Errors.SENDER_NOT_NUCLIFI_CONTROLLER
        );
    }
}
