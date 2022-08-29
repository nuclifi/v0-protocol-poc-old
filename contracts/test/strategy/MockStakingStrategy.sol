// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Errors} from "../../libraries/Errors.sol";
import {MockStaking} from "../../test/staking/MockStaking.sol";
import {INuclifiStrategy} from "../../interfaces/INuclifiStrategy.sol";
import {INuclifiController} from "../../interfaces/INuclifiController.sol";
import {INuclifiCertificate} from "../../interfaces/INuclifiCertificate.sol";

contract MockStakingStrategy is INuclifiStrategy, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public override certificateId;

    MockStaking public stakingProgram;
    IERC20 public stakingProgramStakeToken;
    IERC20 public stakingProgramRewardToken;
    INuclifiController public override nuclifiController;
    INuclifiCertificate public override nuclifiCertificate;

    constructor(
        address stakingProgram_,
        address nuclifiController_,
        address nuclifiCertificate_
    ) {
        require(stakingProgram_.isContract(), Errors.ADDRESS_NOT_CONTRACT);
        require(nuclifiController_.isContract(), Errors.ADDRESS_NOT_CONTRACT);
        require(nuclifiCertificate_.isContract(), Errors.ADDRESS_NOT_CONTRACT);

        emit StrategyInitialized();

        stakingProgram = MockStaking(stakingProgram_);
        nuclifiController = INuclifiController(nuclifiController_);
        nuclifiCertificate = INuclifiCertificate(nuclifiCertificate_);

        stakingProgramRewardToken = IERC20(stakingProgram.rewardsToken());

        IERC20 _stakingProgramStakeToken = IERC20(
            stakingProgram.stakingToken()
        );
        _stakingProgramStakeToken.approve(stakingProgram_, type(uint256).max);
        stakingProgramStakeToken = _stakingProgramStakeToken;
    }

    function setCertificateId(uint256 certificateId_)
        external
        override
        nonReentrant
    {
        _requireCallerIsNuclifiControllerAddress();
        require(certificateId_ > 0, Errors.CERTIFICATE_DOES_NOT_EXIST);
        require(certificateId == 0, Errors.CERTIFICATE_ID_ALREADY_SET);

        emit CertificateIdSet(certificateId_);
        certificateId = certificateId_;
    }

    function invest(uint256 amount_) external override nonReentrant {
        _requireCallerIsNuclifiControllerAddress();
        _requireValueIsNonZero(amount_);
        _requireContractHasBalance(amount_);

        emit Invested(amount_);
        stakingProgram.stake(amount_);
    }

    function withdraw(uint256 amount_) external override nonReentrant {
        _requireCallerIsNuclifiControllerAddress();
        _requireValueIsNonZero(amount_);
        _requireNoFullWithdrawal(amount_);

        _claim();

        emit Redeemed(amount_);
        stakingProgram.withdraw(amount_);

        address _certificateOwner = certificateOwner();
        emit RedemptionSent(_certificateOwner, amount_);
        stakingProgramStakeToken.safeTransfer(_certificateOwner, amount_);
    }

    function redeem() external override nonReentrant {
        _requireCallerIsNuclifiControllerAddress();

        uint256 _amount = stakingProgram.balanceOf(address(this));
        _requireValueIsNonZero(_amount);

        _claim();

        emit Redeemed(_amount);
        stakingProgram.withdraw(_amount);

        address _certificateOwner = certificateOwner();
        emit RedemptionSent(_certificateOwner, _amount);
        stakingProgramStakeToken.safeTransfer(_certificateOwner, _amount);
    }

    function claim() public override nonReentrant {
        _requireCallerIsNuclifiControllerAddress();
        _claim();
    }

    function _claim() internal {
        _requireCallerIsNuclifiControllerAddress();

        address _certificateOwner = certificateOwner();

        IERC20 _stakingProgramRewardToken = stakingProgramRewardToken;
        uint256 balanceBefore = _stakingProgramRewardToken.balanceOf(
            address(this)
        );
        emit Claimed();
        stakingProgram.getReward();
        uint256 balanceAfter = _stakingProgramRewardToken.balanceOf(
            address(this)
        );

        uint256 reward = balanceAfter.sub(balanceBefore);
        emit ClaimSent(_certificateOwner, reward);
        _stakingProgramRewardToken.safeTransfer(_certificateOwner, reward);
    }

    function earned() external view override returns (uint256) {
        return stakingProgram.earned(address(this));
    }

    function certificateOwner() public view returns (address) {
        return nuclifiCertificate.ownerOf(certificateId);
    }

    function _requireValueIsNonZero(uint256 value_) internal pure {
        require(value_ > 0, Errors.ZERO_VALUE_FOUND);
    }

    function _requireCallerIsNuclifiControllerAddress() internal view {
        require(
            msg.sender == address(nuclifiController),
            Errors.SENDER_NOT_NUCLIFI_CONTROLLER
        );
    }

    function _requireContractHasBalance(uint256 amount_) internal view {
        IERC20 _purchasingToken = IERC20(nuclifiController.purchasingToken());

        require(
            _purchasingToken.balanceOf(address(this)) >= amount_,
            Errors.STRATEGY_BALANCE_LOW
        );
    }

    function _requireNoFullWithdrawal(uint256 amount_) internal view {
        require(
            amount_ < stakingProgram.balanceOf(address(this)),
            Errors.CANNOT_WITHDRAW_ENTIRE_AMOUNT_WITHOUT_REDEEMING
        );
    }
}
