// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

interface IFaucet {

    // Virtual is implicit in interfaces so not needed
    function addFunds() external payable;

    function withdraw(uint256 amount) external;
}
