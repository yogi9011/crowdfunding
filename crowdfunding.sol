// SPDX-License-Identifier: MIT 

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding {

     mapping(address => uint) public contributors;
     address public manager;
     uint public minContribution;
     uint public deadline;
     uint public target;
     uint public raisedAmount;
     uint public noOfContributors;

      struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
      mapping(uint=>Request) public requests;
      uint public numRequests;


     constructor(uint _target , uint _deadline) {
         target = _target; 
         deadline = block.timestamp + _deadline;
         manager = msg.sender;
         minContribution = 100 wei;
     }

     function sendEth() public payable {

       require(deadline > block.timestamp , "Deadline Has Passed");
       require(msg.value >= minContribution , "Min Contribution is not met");

       if(contributors[msg.sender] == 0)
       {
           noOfContributors ++;
       }
       raisedAmount += msg.value;
       contributors[msg.sender] += msg.value;

     }

     function contractBalance() public view returns(uint256) {
         return address(this).balance;
     }

     function refund() public {
         require(block.timestamp > deadline && raisedAmount < target , "Ineligible for refund");
         require(contributors[msg.sender] > 0 , "Ineligible for refund");
         address payable user = payable(msg.sender);
         user.transfer(contributors[msg.sender]);
         contributors[msg.sender] = 0;
     }

     modifier onlyManger(){
        require(msg.sender==manager,"Only manager can calll this function");
        _;
     }

    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManger{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
     }

      function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender]>0,"You must be a contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
     }

      function makePayment(uint _requestNo) public onlyManger{
        require(raisedAmount>=target);
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
     }
}
