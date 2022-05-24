//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lotto is Ownable {

constructor() {

}

    struct Lottos {
        uint maxPlayers;
        string winObject;
        string name;
        bool ended;
        uint price;
        address[] players;
        mapping(address => uint) balance;
        uint startDate;
        uint endDate;
    }

    uint256 totalLottos;
    mapping(uint => Lottos) lottos;
    address payable ceo;

function createLotto(string memory _name, string memory _winObject, uint _maxPlayers, bool _ended, uint _price, uint _startDate, uint _endDate) public onlyOwner {
        address[] memory players;
        Lottos memory newLotto = Lottos(_maxPlayers, _winObject, _name, _ended, _price, players, balance, _startDate, _endDate);
        lottos[totalLottos] = newLotto;
        totalLottos++;
    }

  function enter(uint lottoId) public payable {
        Lottos memory entering = lottos[lottoId];
        require(entering.startDate <= block.timestamp, "Loto not started");
        require(entering.endDate >= block.timestamp, "Loto is already finish")
        require(entering.ended == false, "Loto is already finish");
        require(msg.value == entering.price, "Price not valid");
        require(msg.sender != address(0), "Your address must be different than address 0");
        require(entering.balance[msg.sender] == 0, "You are already connected");
        lottos[lottoId].players[len] = msg.sender;
        entering.balance[msg.sender] += price;
        ceo.transfer(msg.value);
        lottos[lottoId] = entering;
        
  }

  function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, now, lottos)));
}

  function win(uint lottoId) public onlyOwner {
    Lottos memory entering = lottos[lottoId];
    uint winner = random() % entering.length;
    address payable contractAddress = address(this);
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

    function checkLotto(uint i) public view returns (uint, string memory, string memory, bool, uint, address, uint, uint, uint) {
        return (lottos[i].maxPlayers, lottos[i].winObject, lottos[i].name, lottos[i].ended, lottos[i].price, lottos[i].players, lottos[i].balance[msg.sender], lottos[i].startDate, lottos[i].endDate); 
    }
    
}