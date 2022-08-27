// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiController} from "./interfaces/INuclifiController.sol";
import {INuclifiCertificate} from "./interfaces/INuclifiCertificate.sol";
import {INuclifiConfiguration} from "./interfaces/INuclifiConfiguration.sol";

contract NuclifiController is INuclifiController, Ownable {
    using Address for address;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public override totalValueLocked;
    address public override purchasingToken;

    mapping(uint256 => address) public override certificateStrategyAddress;

    INuclifiCertificate public override nuclifiCertificate;
    INuclifiConfiguration public override nuclifiConfiguration;
}
