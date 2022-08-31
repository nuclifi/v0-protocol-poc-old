// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {ERC721, IERC165} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import {Errors} from "./libraries/Errors.sol";
import {INuclifiCertificate} from "./interfaces/INuclifiCertificate.sol";

contract NuclifiCertificate is
    INuclifiCertificate,
    IERC721Enumerable,
    ERC721,
    ReentrancyGuard
{
    using Address for address;

    uint256 public override certificateId;
    address public immutable override nuclifiControllerAddress;

    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index)
        public
        view
        override
        returns (uint256)
    {
        require(
            index < this.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId_` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId_` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId_` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId_
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId_);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId_);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId_);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId_);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId_);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId_ uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId_)
        private
    {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId_;
        _ownedTokensIndex[tokenId_] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId_ uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId_) private {
        _allTokensIndex[tokenId_] = _allTokens.length;
        _allTokens.push(tokenId_);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId_ uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId_)
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId_];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId_];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId_ uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId_) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId_];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId_];
        _allTokens.pop();
    }

    function _requireCallerIsNuclifiControllerAddress() internal view {
        require(
            _msgSender() == nuclifiControllerAddress,
            Errors.SENDER_NOT_NUCLIFI_CONTROLLER
        );
    }
}
