# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Use ERC721A instead ERC721 | 1 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 1 |
| [GAS-3](#GAS-3) | Use assembly to check for `address(0)` | 1 |
| [GAS-4](#GAS-4) | State variables should be cached in stack variables rather than re-reading them from storage | 1 |
| [GAS-5](#GAS-5) | For Operations that will not overflow, you could use unchecked | 30 |
| [GAS-6](#GAS-6) | Use Custom Errors instead of Revert Strings to save Gas | 4 |
| [GAS-7](#GAS-7) | Avoid contract existence checks by using low level calls | 1 |
| [GAS-8](#GAS-8) | State variables only set in the constructor should be declared `immutable` | 4 |
| [GAS-9](#GAS-9) | Functions guaranteed to revert when called by normal users can be marked `payable` | 3 |
| [GAS-10](#GAS-10) | `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`) | 1 |
| [GAS-11](#GAS-11) | Using `private` rather than `public` for constants, saves gas | 3 |
### <a name="GAS-1"></a>[GAS-1] Use ERC721A instead ERC721
ERC721A standard, ERC721A is an improvement standard for ERC721 tokens. It was proposed by the Azuki team and used for developing their NFT collection. Compared with ERC721, ERC721A is a more gas-efficient standard to mint a lot of of NFTs simultaneously. It allows developers to mint multiple NFTs at the same gas price. This has been a great improvement due to Ethereum's sky-rocketing gas fee.

    Reference: https://nextrope.com/erc721-vs-erc721a-2/

*Instances (1)*:
```solidity
File: interfaces/IOneShot.sol

4: import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

```

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (1)*:
```solidity
File: RapBattle.sol

104:             finalSkill += VIRTUE_INCREMENT;

```

### <a name="GAS-3"></a>[GAS-3] Use assembly to check for `address(0)`
*Saves 6 gas per instance*

*Instances (1)*:
```solidity
File: RapBattle.sol

41:         if (defender == address(0)) {

```

### <a name="GAS-4"></a>[GAS-4] State variables should be cached in stack variables rather than re-reading them from storage
The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (1)*:
```solidity
File: RapBattle.sol

85:         oneShotNft.transferFrom(address(this), _defender, defenderTokenId);

```

### <a name="GAS-5"></a>[GAS-5] For Operations that will not overflow, you could use unchecked

*Instances (30)*:
```solidity
File: CredToken.sol

4: import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

5: import "@openzeppelin/contracts/access/Ownable.sol";

6: import {Streets} from "./Streets.sol";

```

```solidity
File: OneShot.sol

4: import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

5: import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

6: import {Credibility} from "./CredToken.sol";

7: import {IOneShot} from "./interfaces/IOneShot.sol";

8: import {Streets} from "./Streets.sol";

10: import {console} from "forge-std/console.sol";

32:         uint256 tokenId = _nextTokenId++;

```

```solidity
File: RapBattle.sol

4: import {IOneShot} from "./interfaces/IOneShot.sol";

5: import {Credibility} from "./CredToken.sol";

6: import {ICredToken} from "./interfaces/ICredToken.sol";

8: import {console} from "forge-std/console.sol";

22:     uint256 public constant BASE_SKILL = 65; // The starting base skill of a rapper

23:     uint256 public constant VICE_DECREMENT = 5; // -5 for each vice the rapper has

24:     uint256 public constant VIRTUE_INCREMENT = 10; // +10 for each virtue the rapper has

61:         uint256 totalBattleSkill = defenderRapperSkill + challengerRapperSkill;

62:         uint256 totalPrize = defenderBet + _credBet;

95:             finalSkill -= VICE_DECREMENT;

98:             finalSkill -= VICE_DECREMENT;

101:             finalSkill -= VICE_DECREMENT;

104:             finalSkill += VIRTUE_INCREMENT;

```

```solidity
File: Streets.sol

4: import {IOneShot} from "./interfaces/IOneShot.sol";

5: import {Credibility} from "./CredToken.sol";

6: import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

40:         uint256 stakedDuration = block.timestamp - stakes[tokenId].startTime;

41:         uint256 daysStaked = stakedDuration / 1 days;

47:         delete stakes[tokenId]; // Clear staking info

```

```solidity
File: interfaces/IOneShot.sol

4: import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

```

### <a name="GAS-6"></a>[GAS-6] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (4)*:
```solidity
File: CredToken.sol

18:         require(msg.sender == address(_streetsContract), "Not the streets contract");

```

```solidity
File: OneShot.sol

27:         require(msg.sender == address(_streetsContract), "Not the streets contract");

```

```solidity
File: RapBattle.sol

58:         require(defenderBet == _credBet, "RapBattle: Bet amounts do not match");

```

```solidity
File: Streets.sol

39:         require(stakes[tokenId].owner == msg.sender, "Not the token owner");

```

### <a name="GAS-7"></a>[GAS-7] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (1)*:
```solidity
File: RapBattle.sol

78:             uint256 balanceChallenger = credToken.balanceOf(address(msg.sender));

```

### <a name="GAS-8"></a>[GAS-8] State variables only set in the constructor should be declared `immutable`
Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (4)*:
```solidity
File: RapBattle.sol

36:         oneShotNft = IOneShot(_oneShot);

37:         credToken = ICredToken(_credibilityContract);

```

```solidity
File: Streets.sol

26:         oneShotContract = IOneShot(_oneShotContract);

27:         credContract = Credibility(_credibilityContract);

```

### <a name="GAS-9"></a>[GAS-9] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (3)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {

22:     function mint(address to, uint256 amount) public onlyStreetContract {

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {

```

### <a name="GAS-10"></a>[GAS-10] `++i` costs less gas compared to `i++` or `i += 1` (same for `--i` vs `i--` or `i -= 1`)
Pre-increments and pre-decrements are cheaper.

For a `uint256 i` variable, the following is true with the Optimizer enabled at 10k:

**Increment:**

- `i += 1` is the most expensive form
- `i++` costs 6 gas less than `i += 1`
- `++i` costs 5 gas less than `i++` (11 gas less than `i += 1`)

**Decrement:**

- `i -= 1` is the most expensive form
- `i--` costs 11 gas less than `i -= 1`
- `--i` costs 5 gas less than `i--` (16 gas less than `i -= 1`)

Note that post-increments (or post-decrements) return the old value before incrementing or decrementing, hence the name *post-increment*:

```solidity
uint i = 1;  
uint j = 2;
require(j == i++, "This will be false as i is incremented after the comparison");
```
  
However, pre-increments (or pre-decrements) return the new value:
  
```solidity
uint i = 1;  
uint j = 2;
require(j == ++i, "This will be true as i is incremented before the comparison");
```

In the pre-increment case, the compiler has to create a temporary variable (when used) for returning `1` instead of `2`.

Consider using pre-increments and pre-decrements where they are relevant (meaning: not where post-increments/decrements logic are relevant).

*Saves 5 gas per instance*

*Instances (1)*:
```solidity
File: OneShot.sol

32:         uint256 tokenId = _nextTokenId++;

```

### <a name="GAS-11"></a>[GAS-11] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (3)*:
```solidity
File: RapBattle.sol

22:     uint256 public constant BASE_SKILL = 65; // The starting base skill of a rapper

23:     uint256 public constant VICE_DECREMENT = 5; // -5 for each vice the rapper has

24:     uint256 public constant VIRTUE_INCREMENT = 10; // +10 for each virtue the rapper has

```


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked` | 1 |
| [NC-2](#NC-2) | `constant`s should be defined rather than using magic numbers | 3 |
| [NC-3](#NC-3) | Delete rogue `console.log` imports | 2 |
| [NC-4](#NC-4) | Consider disabling `renounceOwnership()` | 2 |
| [NC-5](#NC-5) | Function ordering does not follow the Solidity style guide | 1 |
| [NC-6](#NC-6) | Functions should not be longer than 50 lines | 14 |
| [NC-7](#NC-7) | Lack of checks in setters | 3 |
| [NC-8](#NC-8) | Missing Event for critical parameters change | 3 |
| [NC-9](#NC-9) | NatSpec is completely non-existent on functions that should have them | 8 |
| [NC-10](#NC-10) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 3 |
| [NC-11](#NC-11) | Consider using named mappings | 1 |
| [NC-12](#NC-12) | Contract does not follow the Solidity style guide's suggested layout ordering | 3 |
| [NC-13](#NC-13) | Event is missing `indexed` fields | 4 |
| [NC-14](#NC-14) | `public` functions not called by the contract should be declared `external` instead | 7 |
### <a name="NC-1"></a>[NC-1] Use `string.concat()` or `bytes.concat()` instead of `abi.encodePacked`
Solidity version 0.8.4 introduces `bytes.concat()` (vs `abi.encodePacked(<bytes>,<bytes>)`)

Solidity version 0.8.12 introduces `string.concat()` (vs `abi.encodePacked(<str>,<str>), which catches concatenation errors (in the event of a `bytes` data mixed in the concatenation)`)

*Instances (1)*:
```solidity
File: RapBattle.sol

65:             uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % totalBattleSkill;

```

### <a name="NC-2"></a>[NC-2] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (3)*:
```solidity
File: Streets.sol

54:         if (daysStaked >= 2) {

58:         if (daysStaked >= 3) {

62:         if (daysStaked >= 4) {

```

### <a name="NC-3"></a>[NC-3] Delete rogue `console.log` imports
These shouldn't be deployed in production

*Instances (2)*:
```solidity
File: OneShot.sol

10: import {console} from "forge-std/console.sol";

```

```solidity
File: RapBattle.sol

8: import {console} from "forge-std/console.sol";

```

### <a name="NC-4"></a>[NC-4] Consider disabling `renounceOwnership()`
If the plan for your project does not include eventually giving up all ownership control, consider overwriting OpenZeppelin's `Ownable`'s `renounceOwnership()` function in order to disable it.

*Instances (2)*:
```solidity
File: CredToken.sol

8: contract Credibility is ERC20, Ownable {

```

```solidity
File: OneShot.sol

12: contract OneShot is IOneShot, ERC721URIStorage, Ownable {

```

### <a name="NC-5"></a>[NC-5] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (1)*:
```solidity
File: RapBattle.sol

1: 
   Current order:
   external goOnStageOrBattle
   internal _battle
   public getRapperSkill
   
   Suggested order:
   external goOnStageOrBattle
   public getRapperSkill
   internal _battle

```

### <a name="NC-6"></a>[NC-6] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (14)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {

22:     function mint(address to, uint256 amount) public onlyStreetContract {

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {

60:     function getRapperStats(uint256 tokenId) public view returns (RapperStats memory) {

64:     function getNextTokenId() public view returns (uint256) {

```

```solidity
File: RapBattle.sol

40:     function goOnStageOrBattle(uint256 _tokenId, uint256 _credBet) external {

56:     function _battle(uint256 _tokenId, uint256 _credBet) internal {

91:     function getRapperSkill(uint256 _tokenId) public view returns (uint256 finalSkill) {

```

```solidity
File: Streets.sol

84:     function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {

```

```solidity
File: interfaces/ICredToken.sol

7:     function approve(address to, uint256 amount) external;

9:     function transfer(address to, uint256 amount) external;

11:     function transferFrom(address from, address to, uint256 amount) external;

13:     function balanceOf(address user) external returns (uint256 balance);

```

```solidity
File: interfaces/IOneShot.sol

19:     function getRapperStats(uint256 tokenId) external view returns (RapperStats memory);

```

### <a name="NC-7"></a>[NC-7] Lack of checks in setters
Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (3)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {
            _streetsContract = Streets(streetsContract);

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {
            _streetsContract = Streets(streetsContract);

41:     function updateRapperStats(
            uint256 tokenId,
            bool weakKnees,
            bool heavyArms,
            bool spaghettiSweater,
            bool calmAndReady,
            uint256 battlesWon
        ) public onlyStreetContract {
            RapperStats storage metadata = rapperStats[tokenId];
            metadata.weakKnees = weakKnees;
            metadata.heavyArms = heavyArms;
            metadata.spaghettiSweater = spaghettiSweater;
            metadata.calmAndReady = calmAndReady;
            metadata.battlesWon = battlesWon;

```

### <a name="NC-8"></a>[NC-8] Missing Event for critical parameters change
Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (3)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {
            _streetsContract = Streets(streetsContract);

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {
            _streetsContract = Streets(streetsContract);

41:     function updateRapperStats(
            uint256 tokenId,
            bool weakKnees,
            bool heavyArms,
            bool spaghettiSweater,
            bool calmAndReady,
            uint256 battlesWon
        ) public onlyStreetContract {
            RapperStats storage metadata = rapperStats[tokenId];
            metadata.weakKnees = weakKnees;
            metadata.heavyArms = heavyArms;
            metadata.spaghettiSweater = spaghettiSweater;
            metadata.calmAndReady = calmAndReady;
            metadata.battlesWon = battlesWon;

```

### <a name="NC-9"></a>[NC-9] NatSpec is completely non-existent on functions that should have them
Public and external functions that aren't view or pure should have NatSpec comments

*Instances (8)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {

22:     function mint(address to, uint256 amount) public onlyStreetContract {

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {

31:     function mintRapper() public {

41:     function updateRapperStats(

```

```solidity
File: RapBattle.sol

40:     function goOnStageOrBattle(uint256 _tokenId, uint256 _credBet) external {

```

```solidity
File: Streets.sol

31:     function stake(uint256 tokenId) external {

38:     function unstake(uint256 tokenId) external {

```

### <a name="NC-10"></a>[NC-10] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (3)*:
```solidity
File: CredToken.sol

18:         require(msg.sender == address(_streetsContract), "Not the streets contract");

```

```solidity
File: OneShot.sol

27:         require(msg.sender == address(_streetsContract), "Not the streets contract");

```

```solidity
File: Streets.sol

39:         require(stakes[tokenId].owner == msg.sender, "Not the token owner");

```

### <a name="NC-11"></a>[NC-11] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (1)*:
```solidity
File: OneShot.sol

17:     mapping(uint256 => RapperStats) public rapperStats;

```

### <a name="NC-12"></a>[NC-12] Contract does not follow the Solidity style guide's suggested layout ordering
The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (3)*:
```solidity
File: CredToken.sol

1: 
   Current order:
   VariableDeclaration._streetsContract
   FunctionDefinition.constructor
   FunctionDefinition.setStreetsContract
   ModifierDefinition.onlyStreetContract
   FunctionDefinition.mint
   
   Suggested order:
   VariableDeclaration._streetsContract
   ModifierDefinition.onlyStreetContract
   FunctionDefinition.constructor
   FunctionDefinition.setStreetsContract
   FunctionDefinition.mint

```

```solidity
File: OneShot.sol

1: 
   Current order:
   VariableDeclaration._nextTokenId
   VariableDeclaration._streetsContract
   VariableDeclaration.rapperStats
   FunctionDefinition.constructor
   FunctionDefinition.setStreetsContract
   ModifierDefinition.onlyStreetContract
   FunctionDefinition.mintRapper
   FunctionDefinition.updateRapperStats
   FunctionDefinition.getRapperStats
   FunctionDefinition.getNextTokenId
   
   Suggested order:
   VariableDeclaration._nextTokenId
   VariableDeclaration._streetsContract
   VariableDeclaration.rapperStats
   ModifierDefinition.onlyStreetContract
   FunctionDefinition.constructor
   FunctionDefinition.setStreetsContract
   FunctionDefinition.mintRapper
   FunctionDefinition.updateRapperStats
   FunctionDefinition.getRapperStats
   FunctionDefinition.getNextTokenId

```

```solidity
File: Streets.sol

1: 
   Current order:
   StructDefinition.Stake
   VariableDeclaration.stakes
   VariableDeclaration.oneShotContract
   VariableDeclaration.credContract
   EventDefinition.Staked
   EventDefinition.Unstaked
   FunctionDefinition.constructor
   FunctionDefinition.stake
   FunctionDefinition.unstake
   FunctionDefinition.onERC721Received
   
   Suggested order:
   VariableDeclaration.stakes
   VariableDeclaration.oneShotContract
   VariableDeclaration.credContract
   StructDefinition.Stake
   EventDefinition.Staked
   EventDefinition.Unstaked
   FunctionDefinition.constructor
   FunctionDefinition.stake
   FunctionDefinition.unstake
   FunctionDefinition.onERC721Received

```

### <a name="NC-13"></a>[NC-13] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (4)*:
```solidity
File: RapBattle.sol

29:     event OnStage(address indexed defender, uint256 tokenId, uint256 credBet);

30:     event Battle(address indexed challenger, uint256 tokenId, address indexed winner);

```

```solidity
File: Streets.sol

22:     event Staked(address indexed owner, uint256 tokenId, uint256 startTime);

23:     event Unstaked(address indexed owner, uint256 tokenId, uint256 stakedDuration);

```

### <a name="NC-14"></a>[NC-14] `public` functions not called by the contract should be declared `external` instead

*Instances (7)*:
```solidity
File: CredToken.sol

13:     function setStreetsContract(address streetsContract) public onlyOwner {

22:     function mint(address to, uint256 amount) public onlyStreetContract {

```

```solidity
File: OneShot.sol

22:     function setStreetsContract(address streetsContract) public onlyOwner {

31:     function mintRapper() public {

41:     function updateRapperStats(

60:     function getRapperStats(uint256 tokenId) public view returns (RapperStats memory) {

64:     function getNextTokenId() public view returns (uint256) {

```


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | Use a 2-step ownership transfer pattern | 2 |
| [L-2](#L-2) | Prevent accidentally burning tokens | 1 |
| [L-3](#L-3) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 4 |
| [L-4](#L-4) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 2 |
| [L-5](#L-5) | Unsafe ERC20 operation(s) | 8 |
### <a name="L-1"></a>[L-1] Use a 2-step ownership transfer pattern
Recommend considering implementing a two step process where the owner or admin nominates an account and the nominated account needs to call an `acceptOwnership()` function for the transfer of ownership to fully succeed. This ensures the nominated EOA account is a valid and active account. Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (2)*:
```solidity
File: CredToken.sol

8: contract Credibility is ERC20, Ownable {

```

```solidity
File: OneShot.sol

12: contract OneShot is IOneShot, ERC721URIStorage, Ownable {

```

### <a name="L-2"></a>[L-2] Prevent accidentally burning tokens
Minting and burning tokens to address(0) prevention

*Instances (1)*:
```solidity
File: CredToken.sol

23:         _mint(to, amount);

```

### <a name="L-3"></a>[L-3] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`
The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (4)*:
```solidity
File: CredToken.sol

2: pragma solidity ^0.8.20;

```

```solidity
File: OneShot.sol

2: pragma solidity ^0.8.20;

```

```solidity
File: RapBattle.sol

2: pragma solidity ^0.8.20;

```

```solidity
File: Streets.sol

2: pragma solidity ^0.8.20;

```

### <a name="L-4"></a>[L-4] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`
Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (2)*:
```solidity
File: CredToken.sol

5: import "@openzeppelin/contracts/access/Ownable.sol";

```

```solidity
File: OneShot.sol

4: import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

```

### <a name="L-5"></a>[L-5] Unsafe ERC20 operation(s)

*Instances (8)*:
```solidity
File: RapBattle.sol

48:             oneShotNft.transferFrom(msg.sender, address(this), _tokenId);

49:             credToken.transferFrom(msg.sender, address(this), _credBet);

74:             credToken.transfer(_defender, defenderBet);

75:             credToken.transferFrom(msg.sender, _defender, _credBet);

81:             credToken.transfer(msg.sender, _credBet);

85:         oneShotNft.transferFrom(address(this), _defender, defenderTokenId);

```

```solidity
File: Streets.sol

34:         oneShotContract.transferFrom(msg.sender, address(this), tokenId);

80:         oneShotContract.transferFrom(address(this), msg.sender, tokenId);

```


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 6 |
| [M-2](#M-2) | Using `transferFrom` on ERC721 tokens | 2 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (6)*:
```solidity
File: CredToken.sol

8: contract Credibility is ERC20, Ownable {

11:     constructor() ERC20("Credibility", "CRED") Ownable(msg.sender) {}

13:     function setStreetsContract(address streetsContract) public onlyOwner {

```

```solidity
File: OneShot.sol

12: contract OneShot is IOneShot, ERC721URIStorage, Ownable {

19:     constructor() ERC721("Rapper", "RPR") Ownable(msg.sender) {}

22:     function setStreetsContract(address streetsContract) public onlyOwner {

```

### <a name="M-2"></a>[M-2] Using `transferFrom` on ERC721 tokens
The `transferFrom` function is used instead of `safeTransferFrom` and [it's discouraged by OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/109778c17c7020618ea4e035efb9f0f9b82d43ca/contracts/token/ERC721/IERC721.sol#L84). If the arbitrary address is a contract and is not aware of the incoming ERC721 token, the sent token could be locked.

*Instances (2)*:
```solidity
File: Streets.sol

34:         oneShotContract.transferFrom(msg.sender, address(this), tokenId);

80:         oneShotContract.transferFrom(address(this), msg.sender, tokenId);

```

