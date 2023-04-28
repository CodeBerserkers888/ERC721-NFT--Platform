/*

  ____       ____        _       _   _                 
 |  _ \__  _/ ___|  ___ | |_   _| |_(_) ___  _ __  ___ 
 | | | \ \/ \___ \ / _ \| | | | | __| |/ _ \| '_ \/ __|
 | |_| |>  < ___) | (_) | | |_| | |_| | (_) | | | \__ \
 |____//_/\_|____/ \___/|_|\__,_|\__|_|\___/|_| |_|___/
                                                       

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./NFTAwarding.sol";

contract NFTStakingPerToken is Context, IERC721Receiver {
    IERC721 public nft;
    IERC20 public rewardToken;
    address public rewardWallet;
    uint256 public rewardPerTokenPerDay;

    mapping(uint256 => address) private stakedTokens;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lastUpdateTime;
    mapping(address => uint256) private reward;
    NFTAwarding public nftAwarding;

    /**
     * @param nftAddress  Staked NFT Address
     * @param rewardTokenAddress Reward Token Address
     * @param rewardWalletAddress Wallet that holds rewards to be paid out
     * @param rewardRate # of tokens per staked NFT per day
     */
    constructor(
        address nftAddress,
        address rewardTokenAddress,
        address rewardWalletAddress,
        uint256 rewardRate,
        address nftAwardingAddress
    ) {
        nft = IERC721(nftAddress);
        rewardToken = IERC20(rewardTokenAddress);
        rewardWallet = rewardWalletAddress;
        rewardPerTokenPerDay = rewardRate;
        nftAwarding = NFTAwarding(nftAwardingAddress);
    }

    modifier update(address account) {
        reward[account] = available(account);
        lastUpdateTime[account] = block.timestamp;
        _;
    }

    /**
     * @dev returns the number of reward tokens available for an address
     * @param account account
     */
    function available(address account) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastUpdateTime[account];
        uint256 earned = (balanceOf[account] *
            timeElapsed *
            rewardPerTokenPerDay) / 86400;
        return reward[account] + earned;
    }

    /**
     * @dev stakes a specific tokenID
     * @param tokenId tokenId
     */
    function stake(uint256 tokenId) external {
        nft.safeTransferFrom(_msgSender(), address(this), tokenId);
        nftAwarding.distributeRandomNFT();
    }

    /**
     * @dev withdraws a token from the staking contract
     * @param tokenId tokenId
     */
    function withdraw(uint256 tokenId) external update(_msgSender()) {
        require(stakedTokens[tokenId] == _msgSender(), "Token is not staked.");
        delete stakedTokens[tokenId];
        balanceOf[_msgSender()]--;
        nft.transferFrom(address(this), _msgSender(), tokenId);
    }

}