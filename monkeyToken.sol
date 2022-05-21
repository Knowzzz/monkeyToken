//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "https://github.com/Knowzzz/portfolioKnowz/blob/main/admin.sol";

//=========================================================================================================//
//=============================================== MONKEY TOKEN ============================================//
//=========================================================================================================//



/* 
Fonction utiles : 
=============================================== PUBLIC ================================================
---> TransferFrom ==> transférer un token à une autre personne
---> balanceOf ==> voir le nombre de token qu'à un utilisateur
---> mint ==> minter un token
---> mintWhitelisted ==> minter un token lorsque nous sommes whitelist 

=============================================== ADMIN / OWNER ==============================================
---> addTokenWhitelist ==> ajouter un token whitelist sur l'adresse voulu
---> pause / unpause ==> mettre pause / unpause au contrat 

=============================================== OWNER =================================================
--> setDepositAddress ==> changer d'adresse où se dépose l'argent

=======================================================================================================
*/

contract MonkeyToken is ERC721, ERC721Enumerable, Pausable, Admin {

    constructor() ERC721("Monkey Token", "MONKEY") {
  }

  using Counters for Counters.Counter;

  Counters.Counter private _tokenIds;

  address payable public depositAddress = payable(0x274a4E4F93082738F1c142a9040C3DFAa632245e);
  address private devAddress = 0x274a4E4F93082738F1c142a9040C3DFAa632245e;

  uint256 public maxSupply = 100;
  uint256 public price = 0.01 ether;
  uint256 public whitelistPrice = 0.002 ether;
  bool pauseOrNot = false;

  mapping(address => uint8) addressWhitelist;

  
  function setDepositAddress(address payable to) public onlyOwner {
    depositAddress = to;
  }

  function setPrice(uint newPrice) public onlyAdmin {
    newPrice = price;
  }

  function setWhitelistPrice(uint newWlPrice) public onlyAdmin {
    newWlPrice = whitelistPrice;
  }

  string baseURI = "ipfs://QmfLCh8gVaFbGMKwn6ska3fh2wz8dcm4n5ADcx5hADcegi";

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

  function mint(uint amount) public payable {
    require(pauseOrNot == false);
    require(msg.value == price * amount, "Montant Invalide");
    depositAddress.transfer(msg.value);
    for (uint8 i = 0; i < amount; i++) {
        internalMint(msg.sender);
      }
  }

  function mintWhitelisted() public payable {
    require(pauseOrNot == false);
     require(addressWhitelist[msg.sender] > 0, "The address can no longer pre-order");
    require(msg.value == whitelistPrice, "Montant Invalide");
    depositAddress.transfer(msg.value);
    addressWhitelist[msg.sender] -= 1;
      for (uint8 i = 0; i < 1; i++) {
        internalMint(msg.sender);
      }
    }

    function addTokenWhitelist(address[] memory _addresses) external onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != address(0), "Address cannot be 0.");
      require(addressWhitelist[_addresses[i]] == 0, "Balance must be 0.");
      addressWhitelist[_addresses[i]] = 1;
    }
  }

  function pause() public onlyAdmin {
      require(pauseOrNot == false);
    pauseOrNot = true;
  }

  function unpause() public onlyAdmin {
      require(pauseOrNot == true);
    pauseOrNot = false;
  }

  function internalMint(address to) internal {
    require(totalSupply() < maxSupply, "Tous les NFT sont deja mintes");
    _safeMint(to, _tokenIds.current() + 1);
    _tokenIds.increment();
  }

  function withdraw(address addr) public onlyOwner {
    payable(addr).transfer(address(this).balance);
}

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) whenNotPaused {
    super._beforeTokenTransfer(from, to, tokenId);
  }

function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

}