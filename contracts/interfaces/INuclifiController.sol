// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {INuclifiCertificate} from "./INuclifiCertificate.sol";
import {INuclifiConfiguration} from "./INuclifiConfiguration.sol";

interface INuclifiController {
    function claim(uint256 certificateId_) external;

    function redeem(uint256 certificateId_) external;

    function withdraw(uint256 certificateId_, uint256 amount_) external;

    function setAddresses(
        address purchasingTokenAddress_,
        address nuclifiCertificateAddress_,
        address nuclifiConfigurationAddress_
    ) external;

    function purchase(uint256 strategyId_, uint256 amount_) external;

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

    event PurchasingTokenAddressChanged(address purchasingTokenAddress_);
    event NuclifiCertificateAddressChanged(address nuclifiCertificateAddress_);
    event NuclifiConfigurationAddressChanged(
        address nuclifiConfigurationAddress_
    );
    event StrategyLinked(
        uint256 certificateId_,
        uint256 strategyId_,
        address strategy_
    );
}
