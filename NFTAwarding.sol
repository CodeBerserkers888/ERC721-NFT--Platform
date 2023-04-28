/*

  ____       ____        _       _   _                 
 |  _ \__  _/ ___|  ___ | |_   _| |_(_) ___  _ __  ___ 
 | | | \ \/ \___ \ / _ \| | | | | __| |/ _ \| '_ \/ __|
 | |_| |>  < ___) | (_) | | |_| | |_| | (_) | | | \__ \
 |____//_/\_|____/ \___/|_|\__,_|\__|_|\___/|_| |_|___/
                                                       

```````````````````````````````````````````````````````````````````````
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC165.sol";
import "./IERC721.sol";

contract NFTAwarding is IERC721 {
    address public administrator;

    /**
     * @dev Constructor that sets the administrator of the contract.
     */
    constructor(address _administrator) public {
        administrator = _administrator;
    }

    /**
     * @dev Function that distributes NFTs randomly among players.
     * Only administrators should be able to call this function.
     */
    function distributeRandomNFT(address[] players) public {
        require(msg.sender == administrator, "Only administrators can distribute NFTs");

        NFTCollection nftCollection = NFTCollection(address(this));
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 tokenId = nftCollection.tokenByIndex(uint256(keccak256(abi.encodePacked(now, player))) % nftCollection.totalSupply());
            nftCollection.transferFrom(administrator, player, tokenId);
        }
    }

    /**
     * @dev Function that awards NFTs to players for the best performance in the game.
     * Only administrators should be able to call this function.
     */
    function awardNFT(address _player, uint256 _tokenId) public {
        require(msg.sender == administrator, "Only administrators can award NFTs");

        NFTCollection nftCollection = NFTCollection(address(this));
        nftCollection.transferFrom(administrator, _player, _tokenId);
    }
}