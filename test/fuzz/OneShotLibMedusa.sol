// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {IHevm} from "../util/IHevm.sol";

import {RapBattle} from "../../src/RapBattle.sol";
import {OneShot} from "../../src/OneShot.sol";
import {Streets} from "../../src/Streets.sol";
import {Credibility} from "../../src/CredToken.sol";
import {IOneShot} from "../../src/interfaces/IOneShot.sol";

contract OneShotLibMedusa {
    RapBattle public rapBattle;
    OneShot public oneShot;
    Streets public streets;
    Credibility public cred;

    //array of address
    address[] public users;
    uint8 public SIZE;
    uint8 public MINTERSIZE;

    //mapping with user and their tokenID
    mapping(address => uint256) public userTokenId;
    address[] public minters;

    uint256 public nbToken;

    IHevm constant vm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    //constructoir to initialize the contracts with all parameters in arguments
    constructor() {
        oneShot = new OneShot();
        cred = new Credibility();
        streets = new Streets(address(oneShot), address(cred));
        rapBattle = new RapBattle(address(oneShot), address(cred));

        oneShot.setStreetsContract(address(streets));
        cred.setStreetsContract(address(streets));

        address user = address(0x11110);
        address challenger = address(0x11111);

        for (uint256 i = 1; i < 5; i++) {
            string memory addr = string(abi.encodePacked("User ", i));
            address userGen = address(bytes20(bytes32(bytes(addr))));
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
            vm.prank(user);
            oneShot.mintRapper();
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
        address from = users[_from];
        address to = users[_to];
        vm.prank(from);
        cred.transferFrom(from, to, _amount);
    }

    function stakeCredToken(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.prank(user);
        oneShot.approve(address(streets), tokenId);
        vm.prank(user);
        streets.stake(tokenId);
    }

    function stakeCredTokenMinter(uint8 _user) external {
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        _user = _user % MINTERSIZE;
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];
        vm.prank(user);
        oneShot.approve(address(streets), tokenId);
        vm.prank(user);
        streets.stake(tokenId);
    }

    function unStake(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.prank(user);
        streets.unstake(tokenId);
    }

    function unStakeCredToken(uint8 _user) external {
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        _user = _user % MINTERSIZE;
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];

        vm.prank(user);
        streets.unstake(tokenId);
    }

    function transferNFT(uint8 _from, uint8 _to) external {
        _from = _from % MINTERSIZE;
        _to = _to % MINTERSIZE;

        address from = users[_from];
        address to = users[_to];
        uint256 tokenId = userTokenId[from];

        vm.prank(from);
        oneShot.transferFrom(from, to, tokenId);
    }

    function transferNFT(uint8 _from, uint8 _to, uint256 _tokenId) private {
        uint256 tokenId = _tokenId % nbToken;
        _from = _from % SIZE;
        _to = _to % SIZE;

        address from = users[_from];
        address to = users[_to];

        vm.prank(from);
        oneShot.transferFrom(from, to, tokenId);
    }

    function mintCredToken(address _user) private {
        vm.prank(_user);
        cred.mint(address(this), 100);
    }

    function mintCredTokenUser(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        vm.prank(address(streets));
        cred.mint(user, 3);
    }

    function setCredTokenStreetsContract(address _streets) private {
        vm.prank(_streets);
        cred.setStreetsContract(_streets);
    }

    function goOnBattle(uint8 _user, uint256 tokenId) private {
        _user = _user % SIZE;
        tokenId = tokenId % nbToken;
        address user = users[_user];
        vm.prank(user);
        oneShot.approve(address(rapBattle), tokenId);
        vm.prank(user);
        cred.approve(address(rapBattle), 3);
        vm.prank(user);
        rapBattle.goOnStageOrBattle(tokenId, 3);
    }

    function goOnBattleMinter(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];
        vm.prank(user);
        oneShot.approve(address(rapBattle), tokenId);
        vm.prank(user);
        cred.approve(address(rapBattle), 3);
        vm.prank(user);
        rapBattle.goOnStageOrBattle(tokenId, 3);
    }

    function goOnBattleMinterWithMint(uint8 _user) external {
        _user = _user % MINTERSIZE;
        console.log("MinterSize ", MINTERSIZE);
        console.log("Minter user number ", _user);
        address user = minters[_user];
        uint256 tokenId = userTokenId[user];

        vm.prank(address(streets));
        cred.mint(user, 3);

        vm.prank(user);
        oneShot.approve(address(rapBattle), tokenId);
        vm.prank(user);
        cred.approve(address(rapBattle), 3);
        vm.prank(user);
        rapBattle.goOnStageOrBattle(tokenId, 3);
    }
}
