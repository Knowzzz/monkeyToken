//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Lotto is Ownable, ERC721 {

    constructor() ERC721("On Luck", "OL") {

    }

    struct Lottos {
        uint maxPlayers;
        string winObject;
        address depositAddress;
        string name;
        bool ended;
        uint price;
    }
    uint256 totalLottos;
    mapping(uint => Lottos) lottos;
    mapping(address => uint) balance;
    address payable ceo;

    function createLotto(string memory _name, address _depositAddress, string memory _winObject, uint _maxPlayers, bool _ended, uint _price) public onlyOwner {
        Lottos memory newLotto = Lottos(_maxPlayers, _winObject, _depositAddress, _name, _ended, _price);
        lottos[totalLottos] = newLotto;
        totalLottos++;
    }
  function enter(uint lottoId) public payable {
        Lottos memory entering = lottos[lottoId];
        require(entering.ended == false, "Loto is already finish");
        require(msg.value == entering.price, "Price not valid");
        require(msg.sender != address(0), "Your address must be different than address 0");
        bool isAlreadyRegister = false;
        for (uint i=0; i<entering.length; i++) {
            if (entering[i] == msg.sender) {
                isAlreadyRegister = true;
            }
        }
        require(isAlreadyRegister == false);
        entering.push(msg.sender);
        entering.depositAddress.transfer(msg.value);
  }

  function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
}

  function win(uint lottoId) public onlyOwner {
    Lottos memory entering = lottos[lottoId];
    uint winner = random() % entering.length;
    ceo.transfer(entering.depositAddress);
    entering.ended = true;
    lottos[lottoId] = entering;
}

    function nbrLotto() public view returns (uint) {
        return totalLottos;
    }

    function withdraw(uint lottoId) public onlyOwner {
        Lottos memory entering = lottos[lottoId];
        ceo.transfer(entering.depositAddress);
    }

    function checkLotto(uint i) public view returns (uint, string memory, address, string memory, bool, uint) {
        return (lottos[i].maxPlayers, lottos[i].winObject, lottos[i].depositAddress, lottos[i].name, lottos[i].ended, lottos[i].price); 
    }
    
}





