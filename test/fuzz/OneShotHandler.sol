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

contract OneShotHandler is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;

    //array of address
    address[] public users;
    uint8 public SIZE;
    uint8 public MINTERSIZE;

    //mapping with user and their tokenID
    mapping(address => uint256) public userTokenId;
    address[] public minters;

    uint256 public nbToken;

    //constructoir to initialize the contracts with all parameters in arguments
    constructor(RapBattle _rapBattle, OneShot _oneShot, Streets _streets, Credibility _cred) {
        oneShot = _oneShot;
        cred = _cred;
        streets = _streets;
        rapBattle = _rapBattle;

        address user = makeAddr("Alice");
        address challenger = makeAddr("Slim Shady");

        for (uint256 i = 1; i < 5; i++) {
            string memory addr = string(abi.encodePacked("User ", vm.toString(i)));
            address userGen = makeAddr(addr);
            users.push(userGen);
        }

        users.push(challenger);
        users.push(user);

        SIZE = uint8(users.length);
    }

    function minter(uint8 _user) external {
        _user = _user % SIZE;
        address user = users[_user];
        uint256 tokenId = userTokenId[user];
        if (tokenId == 0) {
            userTokenId[user] = oneShot.getNextTokenId();
            vm.startPrank(user);
            oneShot.mintRapper();
            vm.stopPrank();
            console.log("User tokenId ", nbToken);
            minters.push(user);
            nbToken++;
            MINTERSIZE = uint8(minters.length);
        }
    }

    function passOneDay() external {
        vm.warp(block.timestamp + 4 days);
    }

    function transferCredTokenFrom(uint8 _from, uint8 _to, uint256 _amount) private {
        _from = _from % SIZE;
        _to = _to % SIZE;
        _amount = bound(_amount, 0, 100);
        address from = users[_from];
        address to = users[_to];
        vm.startPrank(from);
        cred.transferFrom(from, to, _amount);
        vm.stopPrank();
    }

    function stakeCredToken(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.startPrank(user);
        oneShot.approve(address(streets), tokenId);
        streets.stake(tokenId);
        vm.stopPrank();
    }

    function stakeCredTokenMinter(uint8 _user) external {
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        _user = _user % MINTERSIZE;
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];
        vm.startPrank(user);
        oneShot.approve(address(streets), tokenId);
        streets.stake(tokenId);
        vm.stopPrank();
    }

    function unStake(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.startPrank(user);
        streets.unstake(tokenId);
        vm.stopPrank();
    }

    function unStakeCredToken(uint8 _user) external {
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        _user = _user % MINTERSIZE;
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];

        vm.startPrank(user);
        streets.unstake(tokenId);
        vm.stopPrank();
    }

    function transferNFT(uint8 _from, uint8 _to) external {
        _from = _from % MINTERSIZE;
        _to = _to % MINTERSIZE;

        address from = users[_from];
        address to = users[_to];
        uint256 tokenId = userTokenId[from];

        vm.startPrank(from);
        oneShot.transferFrom(from, to, tokenId);
        vm.stopPrank();
    }

    function transferNFT(uint8 _from, uint8 _to, uint256 _tokenId) private {
        uint256 tokenId = _tokenId % nbToken;
        _from = _from % SIZE;
        _to = _to % SIZE;

        address from = users[_from];
        address to = users[_to];

        vm.startPrank(from);
        oneShot.transferFrom(from, to, tokenId);
        vm.stopPrank();
    }

    function mintCredToken(address _user) private {
        vm.startPrank(_user);
        cred.mint(address(this), 100);
        vm.stopPrank();
    }

    function mintCredTokenUser(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        vm.startPrank(address(streets));
        cred.mint(user, 3);
        vm.stopPrank();
    }

    function setCredTokenStreetsContract(address _streets) private {
        vm.startPrank(_streets);
        cred.setStreetsContract(_streets);
        vm.stopPrank();
    }

    function goOnBattle(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), tokenId);
        cred.approve(address(rapBattle), 3);
        rapBattle.goOnStageOrBattle(tokenId, 3);
        vm.stopPrank();
    }

    function goOnBattleMinter(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];
        vm.startPrank(user);
        oneShot.approve(address(rapBattle), tokenId);
        cred.approve(address(rapBattle), 3);
        rapBattle.goOnStageOrBattle(tokenId, 3);
        vm.stopPrank();
    }

    function goOnBattleMinterWithMint(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];

        vm.startPrank(address(streets));
        cred.mint(user, 3);
        vm.stopPrank();

        vm.startPrank(user);
        oneShot.approve(address(rapBattle), tokenId);
        cred.approve(address(rapBattle), 3);
        rapBattle.goOnStageOrBattle(tokenId, 3);
        vm.stopPrank();
    }
}
