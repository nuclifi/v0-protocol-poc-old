// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

library Errors {
    string public constant TX_FAILED = "00";
    string public constant ADDRESS_NOT_CONTRACT = "01";

    string public constant SENDER_NOT_AUTHORIZED = "02";
    string public constant SENDER_NOT_CERTIFICATE_OWNER = "04";
    string public constant SENDER_NOT_NUCLIFI_CONTROLLER = "03";

    string public constant STRATEGY_BALANCE_LOW = "11";
    string public constant STRATEGY_DOES_NOT_EXIST = "05";
    string public constant CERTIFICATE_DOES_NOT_EXIST = "06";
    string public constant CERTIFICATE_ID_ALREADY_SET = "10";
    string public constant CANNOT_WITHDRAW_ENTIRE_AMOUNT_WITHOUT_REDEEMING =
        "11";

    string public constant ZERO_VALUE_FOUND = "07";
    string public constant VALUES_NOT_EQUAL = "08";
    string public constant VALUE_LESS_THAN_MINIMUM_REQUIRED = "09";
    string public constant VALUE_MORE_THAN_MAXIMUM_PERMITTED = "10";

    string public constant OWNER_INDEX_OUT_OF_BOUNDS = "11";
    string public constant GLOBAL_INDEX_OUT_OF_BOUNDS = "12";
}
