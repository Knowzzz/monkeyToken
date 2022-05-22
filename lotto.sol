pragma solidity ^0.8.13;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Lotto is Ownable, ERC721 {

    constructor() {

    }


    struct Lottos {
        uint maxPlayers;
        string winObject;
        address depositAddress;
        string name;
        uint id;
        bool ended;
    }

    Lottos[] private lottos;
    address payable[] public players;
    mapping(address => uint balance);
    uint public price;

    function createLotto(uint _id, string _name, address _depositAddress, string _winObject, uint _maxPlayers, bool _ended) public onlyOwner {
        Lottos memory newLotto = Lottos(_maxPlayers, _winObject, _depositAddress, _name, _id, _ended);
        lottos.push(newLotto);
    }

    function enter(uint lottoId) public payable {
        lottoId = lottos.Lottos.id;
        require(lottos[lottoId].ended == false)
    }

    function totalLottos() public view returns (uint) {
        return lottos.length;
    }

    function checkLotto(uint _id) public view returns (string memory) {
        return lottos[_id].name;
    }





}