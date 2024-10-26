// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRequestQuest } from "./interfaces/IRequestQuest .sol";
import {Compensationibility} from "./CompensationToken.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Training is IERC721Receiver {
    // Struct to hold staking information
    struct Stake {
        uint256 startTime;
        address owner;
    }

    mapping(uint256 tokenId => Stake stake) public stakes;

    // ERC721 token contract
    IRequestQuest  public requestQuest;
    Compensationibility public CompensationContract;

    // Event declarations
    event Staked(address indexed owner, uint256 tokenId, uint256 startTime);
    event Unstaked(address indexed owner, uint256 tokenId, uint256 stakedDuration);

    constructor(address _requestQuest, address _CompensationibilityContract) {
        requestQuest = IRequestQuest (_requestQuest);
        CompensationContract = Compensationibility(_CompensationibilityContract);
    }

    // Stake tokens by transferring them to this contract
    function stake(uint256 tokenId) external {
        stakes[tokenId] = Stake(block.timestamp, msg.sender);
        emit Staked(msg.sender, tokenId, block.timestamp);
        requestQuest.transferFrom(msg.sender, address(this), tokenId);
    }

    // Unstake tokens by transferring them back to their owner
    function unstake(uint256 tokenId) external {
        require(stakes[tokenId].owner == msg.sender, "Not the token owner");
        uint256 stakedDuration = block.timestamp - stakes[tokenId].startTime;
        uint256 daysStaked = stakedDuration / 1 days;

        // Assuming Conquest contract has a function to update metadata properties
        IRequestQuest.ChiikawaStats memory stakedChiikawaStats = requestQuest.getChiikawaStats(tokenId);

        emit Unstaked(msg.sender, tokenId, stakedDuration);
        delete stakes[tokenId]; // Clear staking info

        // Apply changes based on the days staked
        if (daysStaked >= 1) {
            stakedChiikawaStats.smallFeet = false;
            CompensationContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 2) {
            stakedChiikawaStats.weapon = false;
            CompensationContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 3) {
            stakedChiikawaStats.miniBag = false;
            CompensationContract.mint(msg.sender, 1);
        }
        if (daysStaked >= 4) {
            stakedChiikawaStats.calmAndReady = true;
            CompensationContract.mint(msg.sender, 1);
        }

        // Only call the update function if the token was staked for at least one day
        if (daysStaked >= 1) {
            requestQuest.updateChiikawaStats(
                tokenId,
                stakedChiikawaStats.smallFeet,
                stakedChiikawaStats.weapon,
                stakedChiikawaStats.miniBag,
                stakedChiikawaStats.calmAndReady,
                stakedChiikawaStats.battlesWon
            );
        }

        // Continue with unstaking logic (e.g., transferring the token back to the owner)
        requestQuest.transferFrom(address(this), msg.sender, tokenId);
    }

    // Implementing IERC721Receiver so the contract can accept ERC721 tokens
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
