// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

abstract contract Logger {
    uint256 public testNum;

    constructor() {
        testNum = 1000;
    }

    function emitLog() public pure virtual returns (bytes32);

    function test3() internal pure returns (bytes32) {
        return "Hi";
    }
}
