// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiStrategy} from "./interfaces/INuclifiStrategy.sol";
import {INuclifiController} from "./interfaces/INuclifiController.sol";
import {INuclifiCertificate} from "./interfaces/INuclifiCertificate.sol";
import {INuclifiConfiguration} from "./interfaces/INuclifiConfiguration.sol";
import {INuclifiStrategyFactory} from "./interfaces/INuclifiStrategyFactory.sol";

contract NuclifiController is INuclifiController, Ownable, ReentrancyGuard {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public override purchasingToken;

    mapping(uint256 => address) public override certificateStrategyAddress;

    INuclifiCertificate public override nuclifiCertificate;
    INuclifiConfiguration public override nuclifiConfiguration;

    function setAddresses(
        address purchasingTokenAddress_,
        address nuclifiCertificateAddress_,
        address nuclifiConfigurationAddress_
    ) external override onlyOwner nonReentrant {
        require(
            purchasingTokenAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );
        require(
            nuclifiCertificateAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );
        require(
            nuclifiConfigurationAddress_.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );

        emit PurchasingTokenAddressChanged(purchasingTokenAddress_);
        purchasingToken = purchasingTokenAddress_;

        emit NuclifiCertificateAddressChanged(nuclifiCertificateAddress_);
        nuclifiCertificate = INuclifiCertificate(nuclifiCertificateAddress_);

        emit NuclifiConfigurationAddressChanged(nuclifiConfigurationAddress_);
        nuclifiConfiguration = INuclifiConfiguration(
            nuclifiConfigurationAddress_
        );

        renounceOwnership();
    }

    function purchase(uint256 strategyId_, uint256 amount_)
        external
        override
        nonReentrant
    {
        _requireAmountGtThanZero(amount_);

        address _strategyFactoryAddress = nuclifiConfiguration
            .strategyFactoryAddress(strategyId_);
        _requireStrategyExists(_strategyFactoryAddress);
        require(
            _strategyFactoryAddress.isContract(),
            Errors.ADDRESS_NOT_CONTRACT
        );
        INuclifiStrategyFactory strategyFactory = INuclifiStrategyFactory(
            _strategyFactoryAddress
        );

        address _strategyAddress = strategyFactory.deployStrategy();
        _requireStrategyExists(_strategyAddress);
        require(_strategyAddress.isContract(), Errors.ADDRESS_NOT_CONTRACT);
        INuclifiStrategy strategy = INuclifiStrategy(_strategyAddress);

        (bool _success, uint256 certificateId) = nuclifiCertificate
            .purchaseCertificate(_msgSender());
        require(_success, Errors.TX_FAILED);

        strategy.setCertificateId(certificateId);
        certificateStrategyAddress[certificateId] = _strategyAddress;
        emit StrategyLinked(certificateId, strategyId_, _strategyAddress);

        IERC20(purchasingToken).transferFrom(
            _msgSender(),
            _strategyAddress,
            amount_
        );
        strategy.invest(amount_);
    }

    function claim(uint256 certificateId_) external override nonReentrant {
        _requireCallerIsCertificateOwner(certificateId_);

        INuclifiStrategy strategy = INuclifiStrategy(
            certificateStrategyAddress[certificateId_]
        );
        strategy.claim();
    }

    function redeem(uint256 certificateId_) external override nonReentrant {
        _requireCallerIsCertificateOwner(certificateId_);

        INuclifiStrategy strategy = INuclifiStrategy(
            certificateStrategyAddress[certificateId_]
        );
        strategy.redeem();

        (
            bool _success, /* uint256 certificateId */

        ) = nuclifiCertificate.redeemCertificate(certificateId_);
        require(_success, Errors.TX_FAILED);
    }

    function withdraw(uint256 certificateId_, uint256 amount_)
        external
        override
        nonReentrant
    {
        _requireCallerIsCertificateOwner(certificateId_);

        INuclifiStrategy strategy = INuclifiStrategy(
            certificateStrategyAddress[certificateId_]
        );
        strategy.withdraw(amount_);
    }

    function _requireAmountGtThanZero(uint256 amount_) internal pure {
        require(amount_ > 0, Errors.ZERO_VALUE_FOUND);
    }

    function _requireStrategyExists(address strategy_) internal pure {
        require(strategy_ != address(0), Errors.STRATEGY_DOES_NOT_EXIST);
    }

    function _requireCallerIsCertificateOwner(uint256 certificateId_)
        internal
        view
    {
        require(
            _msgSender() == nuclifiCertificate.ownerOf(certificateId_),
            Errors.SENDER_NOT_CERTIFICATE_OWNER
        );
    }
}
