// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Compensationibility} from "./CompensationToken.sol";
import {IRequestQuest } from "./interfaces/IRequestQuest .sol";
import {Training} from "./Training.sol";

contract RequestQuest  is IRequestQuest , ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;
    Training private _training;

    // Mapping from token ID to its stats
    mapping(uint256 => ChiikawaStats) public chiikawaStats;

    constructor() ERC721("Chiikawa", "CKW") Ownable(msg.sender) {}

    // configures training contract address
    function setTraining(address training) public onlyOwner {
        _training = Training(training);
    }

    modifier onlyTraining() {
        require(msg.sender == address(_training), "Not the training contract");
        _;
    }

    function mintChiikawa() public {
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);

        // Initialize metadata for the minted token
        chiikawaStats[tokenId] =
            ChiikawaStats({smallFeet: true, weapon: true, miniBag: true, calmAndReady: false, battlesWon: 0});
    }

    function updateChiikawaStats(
        uint256 tokenId,
        bool smallFeet,
        bool weapon,
        bool miniBag,
        bool calmAndReady,
        uint256 battlesWon
    ) public onlyTraining {
        ChiikawaStats storage metadata = chiikawaStats[tokenId];
        metadata.smallFeet = smallFeet;
        metadata.weapon = weapon;
        metadata.miniBag = miniBag;
        metadata.calmAndReady = calmAndReady;
        metadata.battlesWon = battlesWon;
    }

    /*//////////////////////////////////////////////////////////////
                                  VIEW
    //////////////////////////////////////////////////////////////*/
    function getChiikawaStats(uint256 tokenId) public view returns (ChiikawaStats memory) {
        return chiikawaStats[tokenId];
    }

    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }
}
