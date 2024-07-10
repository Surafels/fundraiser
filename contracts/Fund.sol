// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;


contract FundMe {

    struct fundraised {
        address beneficiery;
        uint goal;
        uint timeDuration;
        bool isGoal;
        bool isTimeDuration;
        uint totalRaised;
        mapping(address=>uint) FundRaised;
        address[] fundersT;
    }

  address public owner;
  mapping(string => fundraised) fundRaiseds;
  mapping(string => bool) fundAvailable;
  string[]  public fundNames;

   event _fund(string _fundName, address indexed _address, uint indexed  _amount, uint _totalRaised,  uint goal);
   event _withdraw(string _fundName, address indexed _beneficiery, uint _amount);
   event _refund(address indexed _add, uint _amount);


    constructor () {
        owner = msg.sender;
    }

    function createFundRaise (string memory _fundName, uint _goal, uint _timeDuration  )  public {

       fundraised storage fundraiser = fundRaiseds[_fundName];
       require(bytes(_fundName).length > 0, 'You should have a fund name');
       require(!fundAvailable[_fundName], 'There is already a fund with current name');
       
       fundraiser.beneficiery = msg.sender;
       fundraiser.goal = _goal * 1 ether;
       fundraiser.timeDuration = block.timestamp + _timeDuration * 1 days;
       fundNames.push(_fundName);
       fundAvailable[_fundName] = true;

    }

    function fund (string memory _fundName) public payable {

        fundraised storage fundraiser = fundRaiseds[_fundName];
        require (fundraiser.goal > 0 , 'fund is not created');
        require(block.timestamp <= fundraiser.timeDuration, ' The fund time duration  is end');
        require(msg.value >0 , "You can't fund 0 ");

        fundraiser.FundRaised[msg.sender]+= msg.value;
        fundraiser.totalRaised += msg.value;
        fundraiser.fundersT.push(msg.sender);

        if(fundraiser.totalRaised >= fundraiser.goal && !fundraiser.isGoal ) {

            fundraiser.isGoal = true;
        }
        emit _fund(_fundName, msg.sender, msg.value, fundraiser.totalRaised, fundraiser.goal);

    }

    function withdrawOrRefund (string memory _fundName) public {

      fundraised storage fundraiser = fundRaiseds[_fundName];
      require(block.timestamp >= fundraiser.timeDuration, 'The fund time duration is end');

    if(fundraiser.isGoal){

    uint256 amt = fundraiser.totalRaised;
    fundraiser.totalRaised = 0 ;
    fundraiser.isTimeDuration = true;
    payable(fundraiser.beneficiery).transfer(amt);
    emit _withdraw(_fundName, fundraiser.beneficiery, amt);

}

    else {
      address [] storage funders = fundraiser.fundersT;
      for(uint i; i< funders.length; i ++) {
        address funder = funders[i];
        uint amount = fundraiser.FundRaised[funder];
        fundraiser.FundRaised[funder] = 0;
        payable(funder).transfer(amount);
        emit _refund(funder, amount);
    }
}

    }

    function listOfFunds () public view returns (string[] memory ){
        return fundNames;
    }
 
    function whoFund(string memory _funders) public view returns(address[] memory){
        fundraised storage fundraiser = fundRaiseds[_funders];
        return fundraiser.fundersT;
    }

}