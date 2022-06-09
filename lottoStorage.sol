//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";



contract Lotto is Ownable, RrpRequesterV0, VRFConsumerBaseV2, KeeperCompatibleInterface {

constructor() RrpRequesterV0(0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd/* a changer selon la chain, BSC TestNet*/) VRFConsumerBaseV2(vrfCoordinator) {
    COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
    s_subscriptionId = 987; // a changer selon le compte chainlink

}


    struct Lottos {
        uint32 minTickets;
        uint32 maxTicketsPerPlayers;
        uint32 nbrWinners;
        uint128 lottoAmount;
        uint128 price;
        uint maxTickets;
        uint startDate;
        uint endDate;
        string name;
        address[] players;
        address payable depositAddress;
        mapping(address => uint) balance;
    }

    uint256 totalLottos;
    mapping(uint => Lottos) lottos;
    uint totalAmount;
    uint128 p = 1 wei;


function createLotto(uint32 _nbrWinners, string memory _name, uint _maxTickets, uint128 _price, uint _startDate, uint _endDate, address payable _depositAddress, uint32 _maxTicketsPerPlayers, uint32 _minTickets) public onlyOwner {
        Lottos storage lotto = lottos[totalLottos++];
        lotto.maxTickets = _maxTickets;
        lotto.name = _name;
        lotto.price = _price * p;
        lotto.startDate = _startDate;
        lotto.endDate = _endDate;
        lotto.lottoAmount = 0;
        lotto.depositAddress = _depositAddress;
        lotto.maxTicketsPerPlayers = _maxTicketsPerPlayers;
        lotto.minTickets = _minTickets;
        lotto.nbrWinners = _nbrWinners;
    }

  function enter(uint lottoId) public payable {
      Lottos storage lotto = lottos[lottoId];
        require(lotto.startDate < block.timestamp, "Loto not started");
        require(lotto.endDate > block.timestamp, "Loto already finish");
        require(msg.value == lotto.price, "Price not valid");
        require(lotto.balance[msg.sender] < lotto.maxTicketsPerPlayers, "You have reached the ticket limit");

        lotto.players.push(msg.sender); 

        lotto.balance[msg.sender] += 1;
        lotto.lottoAmount += lotto.price; 
        totalAmount += lotto.price;  
        if (lotto.players.length == lotto.maxTickets) {
            win(lottoId);
        }
}

        
  

  function win(uint lottoId) public onlyOwner {
    Lottos storage lotto = lottos[lottoId];
    lotto.depositAddress.transfer(lotto.lottoAmount);
    totalAmount = totalAmount - lotto.lottoAmount;
    makeRequestUint256(lottoId);
    
    }

    function nbrLotto() public view returns (uint) {
        return totalLottos;
    }

    function refund(uint lottoId) public onlyOwner {
        Lottos storage lotto = lottos[lottoId];
        uint subPrice = lotto.price * lotto.players.length;
        totalAmount - subPrice;
        uint len = lotto.players.length;
        for(uint i = 0; i < len; i++) {
            payable(lotto.players[i]).transfer(lotto.price);
            lotto.players[i] = lotto.players[lotto.players.length - 1];
            lotto.players.pop();
        }
    }

    function withdraw(uint _amount, address payable addr) public onlyOwner {
        addr.transfer(_amount);
        totalAmount = totalAmount - _amount;
    }

    function deposit(uint _amount) public payable {
        totalAmount += _amount;
    }

    function checkLotto(uint lottoId) public onlyOwner view returns (uint, string memory, uint, uint, uint, uint, address, uint32, uint32, uint32) {
        Lottos storage lotto = lottos[lottoId];
        return (lotto.maxTickets, lotto.name, lotto.price, lotto.startDate, lotto.endDate, lotto.lottoAmount, lotto.depositAddress, lotto.maxTicketsPerPlayers, lotto.minTickets, lotto.nbrWinners); 
    }

    function checkTotalAmount() public onlyOwner view returns (uint) {
        return (totalAmount);
    }

    function changePrice(uint lottoId, uint128 newPrice) public onlyOwner {
        Lottos storage lotto = lottos[lottoId];
        lotto.price = newPrice;
    }

    function changeMaxTickets(uint lottoId, uint newMaxTickets) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.maxTickets = newMaxTickets;
    }


    function changeName(uint lottoId, string memory newName) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.name = newName;
    }


    function changeDepositAddress(uint lottoId, address payable newDepositAddress) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.depositAddress = newDepositAddress;
    }

    function changeStartDate(uint lottoId, uint newStartDate) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.startDate = newStartDate;
    }

    function changeEndDate(uint lottoId, uint newEndDate) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.endDate = newEndDate;
    }

    function changeMaxTicketsPerPlayers(uint lottoId, uint32 newMaxTicketsPerPlayers) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.maxTicketsPerPlayers = newMaxTicketsPerPlayers;
    }

    function changeMinTickets(uint lottoId, uint32 newMinTickets) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.minTickets = newMinTickets;
    }

    function changeNbrWinners(uint lottoId, uint32 newNbrWinners) public {
        Lottos storage lotto = lottos[lottoId];
        lotto.nbrWinners = newNbrWinners;
    }




    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;
    mapping(bytes32 => uint) public requestId_aToLottoId;

    event RequestedUint256(bytes32 indexed requestId);
    event ReceivedUint256(bytes32 indexed requestId, uint256 response);
    event GetWinner(address _winner, uint lottoId);


    function setRequestParameters(address _sponsorWallet) external onlyOwner {
        airnode = 0x9d3C147cA16DB954873A498e0af5852AB39139f2;
        endpointIdUint256 = 0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78;
        sponsorWallet = _sponsorWallet;
    }

    function makeRequestUint256(uint256 lottoId) public { 
        bytes32 requestId = airnodeRrp.makeFullRequest(airnode, endpointIdUint256, address(this), sponsorWallet, address(this), this.fulfillUint256.selector, "");
       // Store the requestId
        expectingRequestWithIdToBeFulfilled[requestId] = true;
        requestId_aToLottoId[requestId] = lottoId;
        emit RequestedUint256(requestId);
    }

    function fulfillUint256(bytes32 requestId, bytes memory data) public onlyAirnodeRrp {
        // Verify the requestId exists
        require(expectingRequestWithIdToBeFulfilled[requestId], "Request ID not known");
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint lottoId = requestId_aToLottoId[requestId];
        Lottos storage lotto = lottos[lottoId];
        uint256 qrngUint256 = abi.decode(data, (uint256));
        if (qrngUint256 == 0) {
            requestRandomWords(lottoId);
        }
        else {
         
        for(uint w; w < lotto.nbrWinners; w++) {
            uint256 winnerUint = qrngUint256 % lotto.players.length;
            qrngUint256 = uint256(keccak256(abi.encode(qrngUint256)));
            address winner = lotto.players[winnerUint];
            emit GetWinner(winner, lottoId);
            lotto.players[winnerUint] = lotto.players[lotto.players.length - 1];
            lotto.players.pop();
        }
         
         emit ReceivedUint256(requestId, qrngUint256);
         delete lottos[lottoId];
         }
     } 

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;
  
    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
  
    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
  
    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 100000;
  
    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;
  
    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  2;
  
    uint256[] public s_randomWords;
    uint256 public s_requestId;

    mapping(uint => uint) public requestIdToLottoId;


    function requestRandomWords(uint lottoId) public onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
          keyHash,
          s_subscriptionId,
          requestConfirmations,
          callbackGasLimit,
          numWords
        );
        requestIdToLottoId[s_requestId] = lottoId;
      }

      
      function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint lottoId = requestIdToLottoId[requestId];
        Lottos storage lotto = lottos[lottoId];
    
        for(uint w; w < lotto.nbrWinners; w++) {
        s_randomWords = randomWords;
        uint256 winnerUint_c = s_randomWords[0] % lotto.players.length;
        s_randomWords[0] = uint256(keccak256(abi.encode(s_randomWords[0])));
        address winner_c = lotto.players[winnerUint_c];
        emit GetWinner(winner_c, lottoId);
        lotto.players[winnerUint_c] = lotto.players[lotto.players.length - 1];
        lotto.players.pop();

        }
        delete lottos[lottoId];
    
      }


  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    function checkUpkeep(bytes calldata/* checkData */, uint lottoId) external view returns (bool upkeepNeeded, bytes memory) {
        Lottos storage lotto = lottos[lottoId];
        upkeepNeeded = (block.timestamp - lotto.startDate) > lotto.endDate - lotto.startDate;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */, uint lottoId) external {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        Lottos storage lotto = lottos[lottoId];
        if ((block.timestamp - lotto.startDate) > lotto.endDate - lotto.startDate) {
            if (lotto.minTickets > lotto.players.length) {
                refund(lottoId);
            }
            else {
                win(lottoId);
            }
            
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }
}