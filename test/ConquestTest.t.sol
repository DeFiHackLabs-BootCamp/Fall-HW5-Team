// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from "../lib/forge-std/src/Test.sol";
import {Conquest} from "../src/Conquest.sol";
import {RequestQuest } from "../src/RequestQuest .sol";
import {Training} from "../src/Training.sol";
import {Compensationibility} from "../src/CompensationToken.sol";
import {IRequestQuest } from "../src/interfaces/IRequestQuest .sol";

contract ConquestTest is Test {
    Conquest conquest;
    RequestQuest  requestQuest ;
    Training training;
    Compensationibility compensation;
    IRequestQuest.ChiikawaStats stats;
    address user;
    address challenger;

    function setUp() public {
        requestQuest  = new RequestQuest ();
        compensation = new Compensationibility();
        training = new Training(address(requestQuest ), address(compensation));
        conquest = new Conquest(address(requestQuest ), address(compensation));
        user = makeAddr("Chiikawa");
        challenger = makeAddr("Anoko");

        requestQuest.setTraining(address(training));
        compensation.setTraining(address(training));
    }

    // mint chiikawa modifier
    modifier mintChiikawa() {
        vm.prank(user);
        requestQuest.mintChiikawa();
        _;
    }

    modifier twoSkilledChiikawa() {
        vm.startPrank(user);
        requestQuest.mintChiikawa();
        requestQuest.approve(address(training), 0);
        training.stake(0);
        vm.stopPrank();

        vm.startPrank(challenger);
        requestQuest.mintChiikawa();
        requestQuest.approve(address(training), 1);
        training.stake(1);
        vm.stopPrank();

        vm.warp(4 days + 1);

        vm.startPrank(user);
        training.unstake(0);
        vm.stopPrank();
        vm.startPrank(challenger);
        training.unstake(1);
        vm.stopPrank();
        _;
    }

    // Test that a user can mint a chiikawa
    function testMintChiikawa() public {
        address testUser = makeAddr("Hachiware");
        vm.prank(testUser);
        requestQuest.mintChiikawa();
        assert(requestQuest.ownerOf(0) == testUser);
    }

    // Test that only the training contract can update chiikawa stats
    function testAccessControlOnUpdateChiikawaStats() public mintChiikawa {
        vm.prank(user);
        vm.expectRevert();
        requestQuest.updateChiikawaStats(0, true, true, true, true, 0);
    }

    // Test that only owner can set training contract
    function testAccessControlOnSetTraining() public {
        vm.prank(user);
        vm.expectRevert();
        requestQuest.setTraining(address(training));
    }

    // test getChiikawaStats
    function testGetChiikawaStats() public mintChiikawa {
        stats = requestQuest.getChiikawaStats(0);

        assert(stats.smallFeet == true);
        assert(stats.weapon == true);
        assert(stats.miniBag == true);
        assert(stats.calmAndReady == false);
        assert(stats.battlesWon == 0);
    }

    // Test getNexTokenId
    function testGetNextTokenId() public mintChiikawa {
        assert(requestQuest.getNextTokenId() == 1);
    }

    // Test that a user can stake a chiikawa
    function testStake() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(training), 0);
        training.stake(0);
        (, address owner) = training.stakes(0);
        assert(owner == address(user));
    }

    // Test that a user can unstake a chiikawa
    function testUnstake() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(training), 0);
        training.stake(0);
        (, address owner) = training.stakes(0);
        assert(owner == address(user));
        training.unstake(0);
        (, address newOwner) = training.stakes(0);
        assert(newOwner == address(0));
    }

    // Test compensation is minted when a chiikawa is staked for at least one day
    function testCompensationMintedWhenChiikawaStakedForOneDay() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(training), 0);
        training.stake(0);
        vm.stopPrank();
        vm.warp(1 days + 1);
        vm.startPrank(user);
        training.unstake(0);

        assert(compensation.balanceOf(address(user)) == 1);
    }

    // Test chiikawa stats are updated when a chiikawa is staked for at least one day
    function testChiikawaStatsUpdatedWhenChiikawaStakedForOneDay() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(training), 0);
        training.stake(0);
        vm.stopPrank();
        vm.warp(4 days + 1);
        vm.startPrank(user);
        training.unstake(0);

        stats = requestQuest.getChiikawaStats(0);
        assert(stats.smallFeet == false);
        assert(stats.weapon == false);
        assert(stats.miniBag == false);
        assert(stats.calmAndReady == true);
        assert(stats.battlesWon == 0);
    }

    // Test that a user can go to weeding
    function testWeeding() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        conquest.weedingOrBattle(0, 0);
        address defender = conquest.defender();
        assert(defender == address(user));
    }

    // Test that chiikawa is transferred to rap battle contract when going on stage
    function testChiikawaTransferredToConquest() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        conquest.weedingOrBattle(0, 0);
        address owner = requestQuest.ownerOf(0);
        assert(owner == address(conquest));
    }

    // test that a user can go on stage and battle
    function testWeedingOrBattle() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        conquest.weedingOrBattle(0, 0);
        vm.stopPrank();
        vm.startPrank(challenger);
        requestQuest.mintChiikawa();
        requestQuest.approve(address(conquest), 1);
        conquest.weedingOrBattle(1, 0);
    }

    // Test that bets must match when going on stage or battling
    function testBetsMustMatch() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        conquest.weedingOrBattle(0, 0);
        vm.stopPrank();
        vm.startPrank(challenger);
        requestQuest.mintChiikawa();
        requestQuest.approve(address(conquest), 1);
        vm.expectRevert();
        conquest.weedingOrBattle(1, 1);
    }

    // Test winner is transferred the bet amount
    function testWinnerTransferredBetAmount(uint256 randomBlock) public twoSkilledChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        compensation.approve(address(conquest), 3);
        console.log("User allowance before battle:", compensation.allowance(user, address(conquest)));
        conquest.weedingOrBattle(0, 3);
        vm.stopPrank();

        vm.startPrank(challenger);
        requestQuest.approve(address(conquest), 1);
        compensation.approve(address(conquest), 3);
        console.log("User allowance before battle:", compensation.allowance(challenger, address(conquest)));

        // Change the block number so we get different RNG
        vm.roll(randomBlock);
        vm.recordLogs();
        conquest.weedingOrBattle(1, 3);
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        // Convert the event bytes32 objects -> address
        address winner = address(uint160(uint256(entries[0].topics[2])));
        assert(compensation.balanceOf(winner) == 7);
    }

    // Test that the defender's NFT is returned to them
    function testDefendersNftReturned() public twoSkilledChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(conquest), 0);
        compensation.approve(address(conquest), 10);
        conquest.weedingOrBattle(0, 3);
        vm.stopPrank();

        vm.startPrank(challenger);
        requestQuest.approve(address(conquest), 1);
        compensation.approve(address(conquest), 10);

        conquest.weedingOrBattle(1, 3);
        vm.stopPrank();

        assert(requestQuest.ownerOf(0) == address(user));
    }

    // test getChiikawaSkill
    function testGetChiikawaSkill() public mintChiikawa {
        uint256 skill = conquest.getChiikawaSkill(0);
        assert(skill == 50);
    }

    // test getChiikawaSkill with updated stats
    function testGetChiikawaSkillAfterStake() public twoSkilledChiikawa {
        uint256 skill = conquest.getChiikawaSkill(0);
        assert(skill == 75);
    }

    // test onERC721Received in Training.sol when staked
    function testOnERC721Received() public mintChiikawa {
        vm.startPrank(user);
        requestQuest.approve(address(training), 0);
        training.stake(0);
        assert(
            training.onERC721Received(address(0), user, 0, "")
                == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
        );
    }

    
}