// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IRequestQuest } from "./interfaces/IRequestQuest .sol";
import {Compensationibility} from "./CompensationToken.sol";
import {ICompensationToken} from "./interfaces/ICompensationToken.sol";

contract Conquest {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IRequestQuest  public requestQuestNft;
    ICompensationToken public CompensationToken;

    // If someone is waiting to battle, the defender will be populated, otherwise address 0
    address public defender;
    uint256 public defenderBet;
    uint256 public defenderTokenId;

    uint256 public constant BASE_SKILL = 65; // The starting base skill of a chiikawa
    uint256 public constant VICE_DECREMENT = 5; // -5 for each vice the chiikawa has
    uint256 public constant VIRTUE_INCREMENT = 10; // +10 for each virtue the chiikawa has

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Weeding(address indexed defender, uint256 tokenId, uint256 CompensationBet);
    event Battle(address indexed challenger, uint256 tokenId, address indexed winner);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(address _requestQuest , address _CompensationibilityContract) {
        requestQuestNft = IRequestQuest (_requestQuest );
        CompensationToken = ICompensationToken(_CompensationibilityContract);
    }

    function weedingOrBattle(uint256 _tokenId, uint256 _compensationBet) external {
        if (defender == address(0)) {
            defender = msg.sender;
            defenderBet = _compensationBet;
            defenderTokenId = _tokenId;

            emit Weeding(msg.sender, _tokenId, _compensationBet);

            requestQuestNft.transferFrom(msg.sender, address(this), _tokenId);
            CompensationToken.transferFrom(msg.sender, address(this), _compensationBet);
        } else {
            // CompensationToken.transferFrom(msg.sender, address(this), _compensationBet);
            _battle(_tokenId, _compensationBet);
        }
    }

    function _battle(uint256 _tokenId, uint256 _compensationBet) internal {
        address _defender = defender;
        require(defenderBet == _compensationBet, "Conquest: Bet amounts do not match");
        uint256 defenderChiikawaSkill = getChiikawaSkill(defenderTokenId);
        uint256 challengerChiikawaSkill = getChiikawaSkill(_tokenId);
        uint256 totalBattleSkill = defenderChiikawaSkill + challengerChiikawaSkill;
        uint256 totalPrize = defenderBet + _compensationBet;

        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % totalBattleSkill;

        // Reset the defender
        defender = address(0);
        emit Battle(msg.sender, _tokenId, random < defenderChiikawaSkill ? _defender : msg.sender);

        // If random <= defenderChiikawaSkill -> defenderChiikawaSkill wins, otherwise they lose
        if (random <= defenderChiikawaSkill) {
            // We give them the money the defender deposited, and the challenger's bet
            CompensationToken.transfer(_defender, defenderBet);
            CompensationToken.transferFrom(msg.sender, _defender, _compensationBet);
        } else {
            // Otherwise, since the challenger never sent us the money, we just give the money in the contract
            CompensationToken.transfer(msg.sender, _compensationBet);
        }
        totalPrize = 0;
        // Return the defender's NFT
        requestQuestNft.transferFrom(address(this), _defender, defenderTokenId);
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW AND PURE
    //////////////////////////////////////////////////////////////*/
    function getChiikawaSkill(uint256 _tokenId) public view returns (uint256 finalSkill) {
        IRequestQuest.ChiikawaStats memory stats = requestQuestNft.getChiikawaStats(_tokenId);
        finalSkill = BASE_SKILL;
        if (stats.smallFeet) {
            finalSkill -= VICE_DECREMENT;
        }
        if (stats.weapon) {
            finalSkill -= VICE_DECREMENT;
        }
        if (stats.miniBag) {
            finalSkill -= VICE_DECREMENT;
        }
        if (stats.calmAndReady) {
            finalSkill += VIRTUE_INCREMENT;
        }
    }
}
