// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import {RapBattle} from "../../src/RapBattle.sol";
import {OneShot} from "../../src/OneShot.sol";
import {Streets} from "../../src/Streets.sol";
import {Credibility} from "../../src/CredToken.sol";
import {IOneShot} from "../../src/interfaces/IOneShot.sol";

import {OneShotHandler} from "./OneShotHandler.sol";

contract OneShotFuzz is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;
    IOneShot.RapperStats stats;

    address user;
    address challenger;

    // Invariant variables
    address onlyStakingChangeStats = makeAddr("OnlyStakingChangeStats");
    uint256 onlyStakingTokenId;

    //OneShotHanlder contract
    OneShotHandler oneShotHandler;

    function setUp() external {
        oneShot = new OneShot();
        cred = new Credibility();
        streets = new Streets(address(oneShot), address(cred));
        rapBattle = new RapBattle(address(oneShot), address(cred));
        user = makeAddr("Alice");
        challenger = makeAddr("Slim Shady");

        oneShot.setStreetsContract(address(streets));
        cred.setStreetsContract(address(streets));

        //initialize the OneShotHandler contract
        oneShotHandler = new OneShotHandler(rapBattle, oneShot, streets, cred);

        bytes4[] memory selectors = new bytes4[](1);
        //selectors[0] = oneShotHandler.unStake.selector;

        //targetSelector(FuzzSelector({addr: address(oneShotHandler), selectors: selectors}));

        targetContract(address(oneShotHandler));

        onlyStakingTokenId = oneShot.getNextTokenId();
        vm.prank(onlyStakingChangeStats);
        oneShot.mintRapper();
    }

    //Invariant that test that the stats should not be change without any action
    function invariant_NoChangeStatsWhithoutAction() external {
        //get user stats
        stats = oneShot.getRapperStats(onlyStakingTokenId);
        assert(stats.battlesWon == 0);
        assert(stats.calmAndReady == false);
        assert(stats.heavyArms == true);
        assert(stats.spaghettiSweater == true);
        assert(stats.weakKnees == true);

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        assert(userBalance == 1);

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        assert(credBalance == 0);
    }

    // Invariant that test that the stats should not be change without any action even if we stake
    function invariant_OnlyUnstakingChangeStats() external {
        vm.startPrank(onlyStakingChangeStats);
        oneShot.approve(address(streets), onlyStakingTokenId);
        streets.stake(onlyStakingTokenId);
        vm.stopPrank();

        //get user stats
        stats = oneShot.getRapperStats(onlyStakingTokenId);
        assert(stats.battlesWon == 0);
        assert(stats.calmAndReady == false);
        assert(stats.heavyArms == true);
        assert(stats.spaghettiSweater == true);
        assert(stats.weakKnees == true);

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        assert(userBalance == 0);

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        assert(credBalance == 0);
    }

    // Invariant that test that the stats should not be change without any action even if we stake and unstake
    function invariant_UnstakingOnlyChangeStatsWith() external {
        vm.startPrank(onlyStakingChangeStats);
        oneShot.approve(address(streets), onlyStakingTokenId);
        streets.stake(onlyStakingTokenId);
        vm.stopPrank();

        vm.startPrank(onlyStakingChangeStats);
        streets.unstake(onlyStakingTokenId);
        vm.stopPrank();

        stats = oneShot.getRapperStats(onlyStakingTokenId);
        assert(stats.battlesWon == 0);
        assert(stats.calmAndReady == false);
        assert(stats.heavyArms == true);
        assert(stats.spaghettiSweater == true);
        assert(stats.weakKnees == true);

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        assert(userBalance == 1);

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        assert(credBalance == 0);
    }

    // stacking should always give the user 1 cred token
    function invariant_UnstakingFourDaysChangeStats() external {
        vm.startPrank(onlyStakingChangeStats);
        oneShot.approve(address(streets), onlyStakingTokenId);
        streets.stake(onlyStakingTokenId);
        vm.stopPrank();

        vm.warp(block.timestamp + 4 days + 1);

        vm.startPrank(onlyStakingChangeStats);
        streets.unstake(onlyStakingTokenId);
        vm.stopPrank();

        stats = oneShot.getRapperStats(onlyStakingTokenId);
        assert(stats.battlesWon == 0);
        assert(stats.calmAndReady == true);
        assert(stats.heavyArms == false);
        assert(stats.spaghettiSweater == false);
        assert(stats.weakKnees == false);

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        assertEq(userBalance, 1, "the balance should be 1");

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        console.log("credBalance", credBalance);
        assert(credBalance == 4);
    }

    function invariant_userBalanceSame() external {
        uint256 userBalanceAfter = oneShot.balanceOf(onlyStakingChangeStats);

        assert(userBalanceAfter == 1);
    }

    //Invariant that test that the stats should not be change without any action
    function invariant_NonTransferOfNFT() external {
        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        assert(userBalance == 1);

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        assert(credBalance == 0);
    }

    // stacking should always give the user 1 cred token
    function invariant_GoOnBattleWithoutApproving() external {
        vm.startPrank(onlyStakingChangeStats);
        oneShot.approve(address(streets), onlyStakingTokenId);
        streets.stake(onlyStakingTokenId);
        vm.stopPrank();

        vm.warp(block.timestamp + 4 days + 1);

        vm.startPrank(onlyStakingChangeStats);
        streets.unstake(onlyStakingTokenId);
        vm.stopPrank();

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(onlyStakingChangeStats);
        //assertEq(userBalance, 1, "the balance should be 1");

        vm.startPrank(onlyStakingChangeStats);
        //oneShot.approve(address(rapBattle), onlyStakingTokenId);
        //cred.approve(address(rapBattle), 3);
        try rapBattle.goOnStageOrBattle(onlyStakingTokenId, 3) {} catch {}
        vm.stopPrank();

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(onlyStakingChangeStats);
        assert(credBalance <= 4);
    }

    // stacking should always give the user 1 cred token
    function invariant_GoOnBattleWithOtherNFT() external {
        address attacker = makeAddr("Attacker");

        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(attacker);
        assert(userBalance == 0);

        vm.startPrank(attacker);
        //oneShot.approve(address(rapBattle), onlyStakingTokenId);
        //cred.approve(address(rapBattle), 3);
        try rapBattle.goOnStageOrBattle(0, 3) {} catch {}
        vm.stopPrank();

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(attacker);
        assert(credBalance == 0);
    }
}
