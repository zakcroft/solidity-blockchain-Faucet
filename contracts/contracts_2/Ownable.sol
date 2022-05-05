// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

contract Ownable {
    // owner is set when deployed
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // _ means run the function body
        _;
    }
}
