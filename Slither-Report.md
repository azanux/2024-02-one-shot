**THIS CHECKLIST IS NOT COMPLETE**. Use `--show-ignored-findings` to show all the results.
Summary
 - [weak-prng](#weak-prng) (1 results) (High)
 - [erc20-interface](#erc20-interface) (3 results) (Medium)
 - [reentrancy-benign](#reentrancy-benign) (1 results) (Low)
 - [timestamp](#timestamp) (2 results) (Low)
 - [pragma](#pragma) (1 results) (Informational)
 - [solc-version](#solc-version) (7 results) (Informational)
 - [naming-convention](#naming-convention) (3 results) (Informational)
 - [immutable-states](#immutable-states) (4 results) (Optimization)
## weak-prng
Impact: High
Confidence: Medium
 - [ ] ID-0
[RapBattle._battle(uint256,uint256)](src/RapBattle.sol#L56-L86) uses a weak PRNG: "[random = uint256(keccak256(bytes)(abi.encodePacked(block.timestamp,block.prevrandao,msg.sender))) % totalBattleSkill](src/RapBattle.sol#L64-L65)" 

src/RapBattle.sol#L56-L86


## erc20-interface
Impact: Medium
Confidence: High
 - [ ] ID-1
[ICredToken](src/interfaces/ICredToken.sol#L4-L14) has incorrect ERC20 function interface:[ICredToken.transferFrom(address,address,uint256)](src/interfaces/ICredToken.sol#L11)

src/interfaces/ICredToken.sol#L4-L14


 - [ ] ID-2
[ICredToken](src/interfaces/ICredToken.sol#L4-L14) has incorrect ERC20 function interface:[ICredToken.approve(address,uint256)](src/interfaces/ICredToken.sol#L7)

src/interfaces/ICredToken.sol#L4-L14


 - [ ] ID-3
[ICredToken](src/interfaces/ICredToken.sol#L4-L14) has incorrect ERC20 function interface:[ICredToken.transfer(address,uint256)](src/interfaces/ICredToken.sol#L9)

src/interfaces/ICredToken.sol#L4-L14


## reentrancy-benign
Impact: Low
Confidence: Medium
 - [ ] ID-4
Reentrancy in [OneShot.mintRapper()](src/OneShot.sol#L31-L38):
	External calls:
	- [_safeMint(msg.sender,tokenId)](src/OneShot.sol#L33)
		- [retval = IERC721Receiver(to).onERC721Received(_msgSender(),from,tokenId,data)](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L467-L480)
	State variables written after the call(s):
	- [rapperStats[tokenId] = RapperStats({weakKnees:true,heavyArms:true,spaghettiSweater:true,calmAndReady:false,battlesWon:0})](src/OneShot.sol#L36-L37)

src/OneShot.sol#L31-L38


## timestamp
Impact: Low
Confidence: Medium
 - [ ] ID-5
[Streets.unstake(uint256)](src/Streets.sol#L38-L81) uses timestamp for comparisons
	Dangerous comparisons:
	- [require(bool,string)(stakes[tokenId].owner == msg.sender,Not the token owner)](src/Streets.sol#L39)
	- [daysStaked >= 1](src/Streets.sol#L50)
	- [daysStaked >= 2](src/Streets.sol#L54)
	- [daysStaked >= 3](src/Streets.sol#L58)
	- [daysStaked >= 4](src/Streets.sol#L62)
	- [daysStaked >= 1](src/Streets.sol#L68)

src/Streets.sol#L38-L81


 - [ ] ID-6
[RapBattle._battle(uint256,uint256)](src/RapBattle.sol#L56-L86) uses timestamp for comparisons
	Dangerous comparisons:
	- [random <= defenderRapperSkill](src/RapBattle.sol#L72)
	- [random < defenderRapperSkill](src/RapBattle.sol#L69)

src/RapBattle.sol#L56-L86


## pragma
Impact: Informational
Confidence: High
 - [ ] ID-7
Different versions of Solidity are used:
	- Version used: ['>=0.4.22<0.9.0', '^0.8.20']
	- [>=0.4.22<0.9.0](lib/forge-std/src/console.sol#L2)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/access/Ownable.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC165.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC4906.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol#L3)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/Context.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/Strings.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/math/Math.sol#L4)
	- [^0.8.20](lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol#L4)
	- [^0.8.20](src/CredToken.sol#L2)
	- [^0.8.20](src/OneShot.sol#L2)
	- [^0.8.20](src/RapBattle.sol#L2)
	- [^0.8.20](src/Streets.sol#L2)
	- [^0.8.20](src/interfaces/ICredToken.sol#L2)
	- [^0.8.20](src/interfaces/IOneShot.sol#L2)

lib/forge-std/src/console.sol#L2


## solc-version
Impact: Informational
Confidence: High
 - [ ] ID-8
Pragma version[^0.8.20](src/OneShot.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/OneShot.sol#L2


 - [ ] ID-9
Pragma version[^0.8.20](src/CredToken.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/CredToken.sol#L2


 - [ ] ID-10
Pragma version[^0.8.20](src/interfaces/ICredToken.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/interfaces/ICredToken.sol#L2


 - [ ] ID-11
Pragma version[^0.8.20](src/interfaces/IOneShot.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/interfaces/IOneShot.sol#L2


 - [ ] ID-12
Pragma version[^0.8.20](src/Streets.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/Streets.sol#L2


 - [ ] ID-13
Pragma version[^0.8.20](src/RapBattle.sol#L2) necessitates a version too recent to be trusted. Consider deploying with 0.8.18.

src/RapBattle.sol#L2


 - [ ] ID-14
solc-0.8.23 is not recommended for deployment

## naming-convention
Impact: Informational
Confidence: High
 - [ ] ID-15
Parameter [RapBattle.getRapperSkill(uint256)._tokenId](src/RapBattle.sol#L91) is not in mixedCase

src/RapBattle.sol#L91


 - [ ] ID-16
Parameter [RapBattle.goOnStageOrBattle(uint256,uint256)._tokenId](src/RapBattle.sol#L40) is not in mixedCase

src/RapBattle.sol#L40


 - [ ] ID-17
Parameter [RapBattle.goOnStageOrBattle(uint256,uint256)._credBet](src/RapBattle.sol#L40) is not in mixedCase

src/RapBattle.sol#L40


## immutable-states
Impact: Optimization
Confidence: High
 - [ ] ID-18
[RapBattle.credToken](src/RapBattle.sol#L15) should be immutable 

src/RapBattle.sol#L15


 - [ ] ID-19
[Streets.credContract](src/Streets.sol#L19) should be immutable 

src/Streets.sol#L19


 - [ ] ID-20
[Streets.oneShotContract](src/Streets.sol#L18) should be immutable 

src/Streets.sol#L18


 - [ ] ID-21
[RapBattle.oneShotNft](src/RapBattle.sol#L14) should be immutable 

src/RapBattle.sol#L14


