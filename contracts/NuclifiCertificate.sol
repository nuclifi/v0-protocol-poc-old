// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiCertificate} from "./interfaces/INuclifiCertificate.sol";

contract NuclifiCertificate is INuclifiCertificate, ERC721, ReentrancyGuard {
    using Address for address;

    uint256 public override certificateId;
    address public immutable override nuclifiControllerAddress;

    constructor(address nuclifiControllerAddress_)
        ERC721("Nucli.fi POC Certificate", "N.Fi")
    {
        require(
            nuclifiControllerAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );

        emit NuclifiCertificateInitialized();
        emit NuclifiControllerAddressChanged(nuclifiControllerAddress_);

        nuclifiControllerAddress = nuclifiControllerAddress_;
    }

    function purchaseCertificate(address to_)
        external
        override
        nonReentrant
        returns (bool, uint256)
    {
        _requireCallerIsNuclifiControllerAddress();

        ++certificateId;
        uint256 _certificateId = certificateId;
        emit CertificatePurchased(to_, _certificateId);
        _mint(to_, _certificateId);

        return (_exists(_certificateId), _certificateId);
    }

    function redeemCertificate(uint256 certificateId_)
        external
        override
        nonReentrant
        returns (bool, uint256)
    {
        _requireCallerIsNuclifiControllerAddress();
        _requireMinted(certificateId_);

        address _owner = ownerOf(certificateId_);
        emit CertificateRedeemed(_owner, certificateId_);
        _burn(certificateId_);

        return (!_exists(certificateId_), certificateId_);
    }

    function tokenId() external view override returns (uint256) {
        return certificateId;
    }

    function _requireCallerIsNuclifiControllerAddress() internal view {
        require(
            _msgSender() == nuclifiControllerAddress,
            Errors.SENDER_NOT_NUCLIFI_CONTROLLER
        );
    }
}
