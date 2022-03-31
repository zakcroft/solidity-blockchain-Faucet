// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

contract Storage {
    mapping(uint256 => uint256) public aa; // slot 0
    mapping(address => uint256) public bb; // slot 1

    uint256[] public cc; // slot 2

    uint8 public a = 7;
    uint8 public b = 10;
    address public c = 0xb67c511e8DE416790Ae1bCCADBF79053AaD14D3B;
    bool public d = true;
    uint64 public e = 15; // slot 3

    uint256 public f = 200;

    uint8 public g = 40;
    uint256 public h = 789;

    constructor() {
        cc.push(1);
        cc.push(10);
        cc.push(100);

        aa[2] = 4;
        aa[3] = 10;
        bb[0xb67c511e8DE416790Ae1bCCADBF79053AaD14D3B] = 100;
    }
}
