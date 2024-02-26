// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHevm} from "./util/IHevm.sol";
import {OneShotLibMedusa} from "./fuzz/OneShotLibMedusa.sol";
import {OneShot} from "../src/OneShot.sol";
import {Credibility} from "../src/CredToken.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {Streets} from "../src/Streets.sol";

contract OneShotMedusa {
    address public owner = address(0x120);
    address public medusa = address(0x123);
    OneShot public oneShot;
    Credibility public cred;
    Streets public streets;
    RapBattle public rapBattle;

    IHevm constant vm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    uint256 onlyStakingTokenId;

    constructor() {
        OneShotLibMedusa oneShotLib = new OneShotLibMedusa();
        oneShot = oneShotLib.oneShot();
        cred = oneShotLib.cred();
        streets = oneShotLib.streets();
        rapBattle = oneShotLib.rapBattle();

        onlyStakingTokenId = oneShot.getNextTokenId();
        vm.prank(medusa);
        oneShot.mintRapper();
    }

    function fuzz_userBalanceSame() external {

        vm.prank(medusa);
        oneShot.approve(address(streets), onlyStakingTokenId);
         vm.prank(medusa);
        streets.stake(onlyStakingTokenId);


        //vm.roll(block.number + 97621);
        vm.warp(block.timestamp + 1 days + 1);

        

        vm.prank(medusa);
        streets.unstake(onlyStakingTokenId);

        
        


        //check user balance should be equal to 0
        uint256 userBalance = oneShot.balanceOf(medusa);
        //assertEq(userBalance, 1, "the balance should be 1");

        //check balance cred token should be equal to zero
        uint256 credBalanceStart = cred.balanceOf(medusa);

        //assert(false);


        vm.prank(medusa);
        //oneShot.approve(address(rapBattle), onlyStakingTokenId);
        //cred.approve(address(rapBattle), 3);
        try rapBattle.goOnStageOrBattle(onlyStakingTokenId, 3) {} catch {}

        //check balance cred token should be equal to zero
        uint256 credBalance = cred.balanceOf(medusa);
        assert(credBalance <= 4 );
    }
}
