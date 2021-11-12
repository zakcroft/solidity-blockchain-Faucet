// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

contract Ownable {
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
