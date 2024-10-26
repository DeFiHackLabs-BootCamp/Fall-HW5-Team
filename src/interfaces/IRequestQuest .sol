// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IRequestQuest  is IERC721 {
    struct ChiikawaStats {
        bool smallFeet;
        bool weapon;
        bool miniBag;
        bool calmAndReady;
        uint256 battlesWon;
    }

    // Mint a new chiikawa token
    function mintChiikawa() external;

    // Add functions for direct metadata manipulation
    function getChiikawaStats(uint256 tokenId) external view returns (ChiikawaStats memory);

    // Update metadata for a token
    function updateChiikawaStats(
        uint256 tokenId,
        bool smallFeet,
        bool weapon,
        bool miniBag,
        bool calmAndReady,
        uint256 battlesWon
    ) external;
}
