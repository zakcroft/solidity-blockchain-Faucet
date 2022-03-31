// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;


contract Faucet  {

    mapping(address => uint256) public fundsByAddress;

    // This will add to the contracts balance
    function addFunds() external payable {
        uint256 senderFunds =  fundsByAddress[msg.sender];
        fundsByAddress[msg.sender] = senderFunds + msg.value;
    }

    // This will withdraw to the contracts balance
    function withdraw(uint256 amount) external {
        uint256 senderFunds =  fundsByAddress[msg.sender];
        require(
            senderFunds >= amount,
            "Cannot withdrawal more than you have"
        );

        fundsByAddress[msg.sender] = senderFunds - amount;

        payable(msg.sender).transfer(amount);
    }

    function getFundersBalance() external view returns (uint256) {
        return fundsByAddress[msg.sender];
    }

    // receives ETH when you send to the contract address
    receive() external payable {}

}

