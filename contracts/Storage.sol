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

//c9513c7232310bb102320b17488c50b8829d9e6bc99d470f591534284f94929c

//1100100101010001001111000111001000110010001100010000101110110001000000100011001000001011000101110100100010001100010100001011100010000010100111011001111001101011110010011001110101000111000011110101100100010101001101000010100001001111100101001001001010011100
