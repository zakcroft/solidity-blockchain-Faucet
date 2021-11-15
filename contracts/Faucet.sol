// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

import "./IFaucet.sol";

import "./Ownable.sol";
import "./Logger.sol";

contract Faucet is Ownable, Logger, IFaucet {
    uint256 public funds = 1000;
    int256 public counter = -10;
    uint256 public numOfFunders;
    mapping(address => bool) private funders;
    mapping(uint256 => address) private lutFunders;
    mapping(address => uint256) public balances;

    //event alreadyFunded(address sender, uint numOfFunders);

    modifier limitWithdrawal(uint256 withdrawAmount) {
        require(
            withdrawAmount <= 100000000000000000,
            "Cannot withdrawal more than 0.1 ether"
        );
        _;
    }

    receive() external payable {}

    function emitLog() public pure override returns (bytes32) {
        return "Hello!";
    }

    function addFunds() external payable override {
        //require(!funders[msg.sender], "Already added funds"); // should be able to do thi.
        // emit alreadyFunded(msg.sender, numOfFunders);
        uint256 index = numOfFunders++;
        funders[msg.sender] = true;
        balances[msg.sender] = msg.value;
        lutFunders[index] = msg.sender;
    }

    function pureFn() external pure returns (uint256) {
        return 2 + 2;
    }

    function viewFn() external view returns (uint256) {
        return funds;
    }

    function getAllFunders() external view returns (address[] memory) {
        address[] memory _funders = new address[](numOfFunders);
        for (uint256 i = 0; i < numOfFunders; i++) {
            _funders[i] = lutFunders[i];
        }
        return _funders;
    }

    function getFunderAtIndex(uint8 i) external view returns (address) {
        return lutFunders[i];
    }

    function withdraw(uint256 amount)
        external
        override
        limitWithdrawal(amount)
    {
        // funders[msg.sender] = false;
        // balances[msg.sender] = balances[msg.sender] - amount;
        payable(msg.sender).transfer(amount);
    }

    function test1() external onlyOwner {
        // some managing stuff that only admin should have access to
    }

    function test2() external onlyOwner {
        // some managing stuff that only admin should have access to
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}

// migrate --reset
//const i = await Faucet.deployed()     100000000000000000
//i.addFunds({ from:accounts[0], value:"2000000000000000000" })
//i.addFunds({ from:accounts[1], value:"1000000000000000000000000000000000000" })
//i.getFunderAtIndex(0)
// i.getAllFunders()

// i.withdraw('2000000000000000000')
// i.test1()
// web3.eth.getBalance(walletAddress);
