// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {INuclifiController} from "./INuclifiController.sol";
import {INuclifiCertificate} from "./INuclifiCertificate.sol";

interface INuclifiStrategy {
    function claim() external;

    function invest(uint256 amount_) external;

    function redeem(uint256 amount_) external;

    function setCertificateId(uint256 certificateId_) external;

    function earned() external view returns (uint256);

    function certificateId() external view returns (uint256 certificateId_);

    function nuclifiCertificate()
        external
        view
        returns (INuclifiCertificate nuclifiCertificate_);

    function nuclifiController()
        external
        view
        returns (INuclifiController nuclifiController_);

    event Claimed();
    event StrategyInitialized();
    event Invested(uint256 amount_);
    event Redeemed(uint256 amount_);
    event ClaimSent(address to_, uint256 amount_);
    event CertificateIdSet(uint256 certificateId_);
    event RedemptionSent(address to_, uint256 amount_);
    event NuclifiCertificateAddressChanged(address nuclifiCertificateAddr_);
}
