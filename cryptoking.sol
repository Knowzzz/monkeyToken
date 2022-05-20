//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;


contract Ownable {
    address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Owner() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

pragma solidity ^0.8.13;

contract CrytpoKing is Ownable {

  constructor() {

  }

    address payable winner1;
    address payable winner2;
    address payable winner3;
    address payable dev;
    address payable contractAddress = address(this);

    uint minAmount = 0.05 ether;

    mapping(address => uint256) public point;

    address[] payable public player;

    function add() public payable {

      require(msg.value == minAmount);
        if (player.points == 0) {
            player.push(player);
            player.points = msg.value;
            player.user = msg.sender;
            
        }
        else {
            point[msg.sender] += msg.value;
        }
    }

    function setWinner() payable {

      uint amountWinner1 = (contractAddress.point * 100) / 2.5;
      uint amountWinner2 = (contractAddress.point * 100) / 1.5;
      uint amountWinner3 = (contractAddress.point * 100) / 1;
      uint amountDev = (contractAddress.point * 100) / 3;

        winner1.transfer(amountWinner1);
        winner2.transfer(amountWinner2);
        winner3.transfer(amountWinner3);
        dev.transfer(amountDev);

    }

    function balanceOf(address _user) public view returns(uint) {
      return point[_user];
    }
    
}