// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

abstract contract Logger {
    uint256 public testNum;

    constructor() {
        testNum = 1000;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Virtual allows the function’s or modifier’s behaviour to be changed in derived contracts.
    function abstractFunctionToImplement() public pure virtual returns (bytes32);

    function test3() internal pure returns (bytes32) {
        return "Hi";
    }
}
