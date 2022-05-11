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