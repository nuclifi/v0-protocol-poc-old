// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INuclifiCertificate is IERC721 {
    function purchaseCertificate(address to_) external returns (bool, uint256);

    function redeemCertificate(uint256 certificateId_)
        external
        returns (bool, uint256);

    function tokenId() external view returns (uint256 certificateId_);

    function certificateId() external view returns (uint256 certificateId_);

    function nuclifiControllerAddress()
        external
        view
        returns (address nuclifiControllerAddress_);

    event NuclifiCertificateInitialized();
    event CertificatePurchased(address indexed to_, uint256 certificateId_);
    event NuclifiControllerAddressChanged(address nuclifiControllerAddress_);
    event CertificateRedeemed(address indexed from_, uint256 certificateId_);
}
