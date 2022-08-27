// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {INuclifiCertificate} from "./INuclifiCertificate.sol";
import {INuclifiConfiguration} from "./INuclifiConfiguration.sol";

interface INuclifiController {
    function totalValueLocked()
        external
        view
        returns (uint256 totalValueLocked_);

    function purchasingToken()
        external
        view
        returns (address purchasingToken_);

    function nuclifiCertificate()
        external
        view
        returns (INuclifiCertificate nuclifiCertificate_);

    function nuclifiConfiguration()
        external
        view
        returns (INuclifiConfiguration nuclifiConfiguration_);

    function certificateStrategyAddress(uint256 certificateId_)
        external
        view
        returns (address);

    event NuclifiCertificateAddressChanged(address nuclifiCertificateAddr_);
    event MockStakingFactoryAddressChanged(address mockStakingFactoryAddr_);
}
