//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

//========================================================================================================//
//========================================== CONTRAT ADMIN ================================================//
//======================================================================================================//


/*
Fonction utiles :
==================================================== OWNER ==============================================
---> listAdmin ==> lister les admins || A corriger
---> addAdmin ==> ajouter un admin 
---> delAdmin ==> retire l'admin choisi 
---> owner ==> renvoie l'owner du contrat
---> renounceOwnership ==> se retire les permissions et les donne à l'adresse 0 (irréverible) /!\ A NE PAS EXECUTER
---> transferOwnership ==> transfère les permissions de l'owner /!\ Attention, ACTION IRREVERISBLE

=================================================== ADMIN ================================================
---> renounceAdmin ==> se retirer des admins 

==========================================================================================================
=================================================== A FAIRE ==============================================
---> Vérifier si une adresse est un admin
==========================================================================================================
 */

contract Admin is Ownable {

    address[] public admin;

    constructor() {
        admin.push(msg.sender);
    }

    function listAdmin() public onlyOwner view returns (uint) {
        return admin.length;
    }

    function addAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0), "l'adresse ne peut pas etre l'adresse 0");
    admin.push(newAdmin);
    }

    function delAdmin(address thisAdmin) public onlyOwner {
        bool _delAdmin = false;
        uint256 index;
        for (uint i=0; i<admin.length; i++) {
            if (admin[i] == thisAdmin) {
                _delAdmin = true;
                index = i;
            }
        }

        require(_delAdmin = true, "l'adresse n'est pas admin");
        admin[index] = admin[admin.length - 1];
        admin.pop(); 
    }

    modifier onlyAdmin() {
        bool admins=false;
        for (uint i=0;i<admin.length;i++){
           if (admin[i]==msg.sender){
               admins=true;
           } 
        }
        require(admins==true);
        _;
    }

    function renounceAdmin() public onlyAdmin {
        bool _delAdmin = false;
        uint256 index;
        for (uint i=0; i<admin.length; i++) {
            if (admin[i] == msg.sender) {
                _delAdmin = true;
                index = i;
            }
        }
        require(_delAdmin = true, "l'adresse n'est pas admin");
        admin[index] = admin[admin.length - 1];
        admin.pop(); 
    }
}

//=========================================================================================================//
//=============================================== MONKEY TOKEN ============================================//
//=========================================================================================================//



/* 
Fonction utiles : 
=============================================== PUBLIC ================================================
--->  ==> transférer un token à une autre personne
---> balanceOf ==> voir le nombre de token qu'à un utilisateur
---> mint ==> minter un token
---> mintWhitelisted ==> minter un token lorsque nous sommes whitelist || A corriger

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

  function mint(uint amount) public payable {
    require(pauseOrNot == false);
    require(msg.value == price * amount, "Montant Invalide");
    depositAddress.transfer(price * amount);
    for (uint8 i = 0; i < amount; i++) {
        internalMint(msg.sender);
      }
  }

  function mintWhitelisted() public payable {
    require(pauseOrNot == false);
     require(addressWhitelist[msg.sender] > 0, "The address can no longer pre-order");
    require(msg.value == whitelistPrice, "Montant Invalide");
    depositAddress.transfer(whitelistPrice);
    addressWhitelist[msg.sender] -= 1;
      for (uint8 i = 0; i < 1; i++) {
        internalMint(msg.sender);
      }
    }

    function addTokenWhitelist(address[] memory _addresses) external onlyOwner {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != address(0), "Address cannot be 0.");
      require(whitelistedAddress[_addresses[i]] == 0, "Balance must be 0.");
      whitelistedAddress[_addresses[i]] = 1;
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
    _safeMint(to, _tokenIds.current());
    _tokenIds.increment();
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) whenNotPaused {
    super._beforeTokenTransfer(from, to, tokenId);
  }

function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

}