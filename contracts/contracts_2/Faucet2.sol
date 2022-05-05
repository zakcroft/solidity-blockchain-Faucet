// SPDX-License-Identifier: MIT
pragma solidity ~0.8.9;

import "./Events.sol";
import "./IFaucet.sol";
import "./Logger.sol";
import "./Ownable.sol";

// Latest docs https://docs.soliditylang.org/en/latest/

// Cheat Sheets
// Better - https://manojpramesh.github.io/solidity-cheatsheet/
// https://docs.soliditylang.org/en/v0.8.13/cheatsheet.html

// good overall walk through
//https://ethereum-blockchain-developer.com/000-learn-ethereum/

// This code reside at the contract address

contract Faucet2 is Ownable, Logger, IFaucet, Events {
    // ints
    uint256 public funds = 1000; //between 0 and (2^256)-1
    int256 public counter = -10; //  public -  visible externally and internally (creates a getter function for storage/state variables)
    uint public numOfFunders; // same as uint256
    uint8 private numOfFunders8; // up to 2^8-1 = 255 //  private only visible in the current contract

    // address can be plain address or address payable which has transfer() and send()
    address public lastFunder;
    address payable public lastFunderPayable; // has transfer() and send()

    mapping(address => bool) private funders; //  addresses are hex 0x46B8054543995DBee01ec6b49bcAB08494f23aA4 // 20 bytes as 40 hex values
    mapping(address => uint256) public balances;
    mapping(uint256 => address) private allFunders;

    address[] public allFundersAlternative; // alternative using an array


    // Strings are quirky and there are bytes and strings

    // bytes
    // A byte is 00000000 to 11111111 which is 8 bits
    // Hex is 0x0 to 0xF or 0000 to 1111 (0 to 9 and then A to F) (base 16)
    // Each HEX is 4 bit sequence
    // so one byte example 0x8F = 10001111
    // https://www.rapidtables.com/convert/number/decimal-to-hex.html

    bytes public strHello = "hello"; // fixed-size byte arrays (bytes1 to bytes32)
    // Each character 1 byte but not for special characters
    // str.length === 5
    // 68 65 6C 6C 6F or 0x68656C6C6F
    // play https://www.rapidtables.com/convert/number/ascii-to-hex.html


    // strings // https://ethereum-blockchain-developer.com/010-solidity-basics/05-string-types/
    // UTF8 so expensive to compute
    // no string functions
    // gas implications as can be infinite size as not fixed-size (Dynamic)
    // use if > bytes32
    string public strWorld = "world";


    // boolean
    bool public yes = true;

    // Structs
    struct Funder {
        address addr;
        uint amount;
    }

    // Funder funder = Funder(addr, 10);
    // funder.addr

    mapping(uint256 => Funder) public allFundersWithStruct;

    // Enums
    enum ActionChoices {
        GoLeft,
        GoRight,
        GoStraight,
        SitStill
    }

    ActionChoices choice = ActionChoices.GoStraight;

    // globals
    //https://docs.soliditylang.org/en/v0.8.13/units-and-global-variables.html?highlight=msg
    // msg.sender (address): sender of the message (current call)
    // msg.value (uint): number of wei sent with the message
    // msg.data (bytes calldata): complete calldata for a function
    // block.timestamp (uint): current block timestamp as seconds since unix epoch

    // receives ETH when you send to the contract address
    //The receive function is executed on a call to the contract with empty calldata.
    receive() external payable {
        // emit the event
        emit MoneyReceived(msg.sender, msg.value);
    }

    // receives ETH when you send to the contract address
    // also receives msg.data
    // called when:
    // - none of the other functions match the given function signature
    // - no data was supplied and no receive() present
    fallback() external payable {
        // emit the event
        emit RunningFallback(msg.sender, msg.value, msg.data);
    }

    // Get the contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // payable means if you send eth to this function in the msg.value if will be added to the contract address
    // external means only visible externally  - i.e. but can be called via this from inside the contract.
    // internal -  only visible internally
    // function visibility cheat sheet https://docs.soliditylang.org/en/v0.8.13/cheatsheet.html?highlight=Visibility#function-visibility-specifiers
    function addFunds() external payable override { //uint[] calldata notCopiedToMemory

        // Check condition. If false rollback
        require(msg.value > 0, "Add some eth");
        require(!funders[msg.sender], "Already added funds");

        // fire event
        emit AlreadyFunded(msg.sender, numOfFunders);

        uint256 index = numOfFunders++;
        funders[msg.sender] = true;
        balances[msg.sender] = msg.value;
        allFunders[index] = msg.sender;

        // Data locations - storage memory or callData - can only be array, struct or mapping types as complex types.
        // Variables in contracts by default are of storage
        // https://www.youtube.com/watch?v=wOCIhzAuhgs
        // https://www.codiesalert.com/storage-vs-memory-vs-calldata/

        // Using a storage variable update the data that persist after the function finishes

        allFundersWithStruct[index] = Funder(msg.sender, msg.value);
        Funder storage funderStore = allFundersWithStruct[index];
        funderStore.amount = msg.value + 1; // will be saved after the function finishes

        // Use memory to read the data that will be lost after function completes - transient
        Funder memory funderMem = allFundersWithStruct[index];
        funderMem.amount = msg.value + 1; // will NOT be saved after the function finishes

        // Internal function can only be run from inside contract
        // The notCopiedToMemory param is non-modifiable storage (calldata) and not copied to memory
        // if passed like this lastFunderFn(notCopiedToMemory);

        lastFunderFn();
    }

    // internal - Can only be called inside the contract
    // if using the notCopiedToMemory param then lastFunderFn(bool calldata notCopiedToMemory)
    function lastFunderFn() internal {
        lastFunder = msg.sender;
    }


    // Modifiers
    modifier limitWithdrawal(uint256 withdrawAmount) {
        require(
            withdrawAmount <= 100000000000000000,
            "Cannot withdrawal more than 0.1 ether"
        );
        _;
    }

    // overriding the abstract or interface
    // Uses modifier
    // notice we don't need to send who is withdrawing as a param, we use msg.sender and make it payable to give it transfer()
    function withdraw(uint256 amount) external override limitWithdrawal(amount) {
         funders[msg.sender] = false;
         balances[msg.sender] = balances[msg.sender] - amount;

        // case the sender address to a payable giving it a transfer and a send function
        payable(msg.sender).transfer(amount);
        emit MoneySent(msg.sender, amount);
    }

    // this is overriding and implementing abstract function
    function abstractFunctionToImplement() public pure override returns (bytes32) {
        return "Hello!";
    }

    // pure disallows modification or access of state.
    function pureFn() external pure returns (uint256) {
        return 2 + 2;
    }

    // view disallows modification of state
    function viewFn() external view returns (uint256) {
        return funds;
    }

    // returns an array of addresses that comes from memory
    function getAllFunders() external view returns (address[] memory) {
        address[] memory _funders = new address[](numOfFunders);
        for (uint256 i = 0; i < numOfFunders; i++) {
            _funders[i] = allFunders[i];
        }
        return _funders;
    }

    function getFunderAtIndex(uint8 i) external view returns (address) {
        return allFunders[i];
    }

    // Uses onlyOwner modifier from the inherited Owner contract
    // Only Owner can run this function
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function getContractBalance() view public returns (uint) {
        return address(this).balance;
    }
}

// migrate --reset - reruns all the migrations

// const i = await Faucet2.deployed()

// i.addFunds([1], { from:accounts[0], value:"2000000000000000000" })
// i.addFunds([1], { from:accounts[1], value:"2000000000000000000"})
// i.getFunderAtIndex(0)
// i.getAllFunders()

// i.lastFunder()  // getter created automatically from lastFunder storage variable

// i.addFunds([1], { from:accounts[1], value:"2000000000000000000"}) // this rollsback as already added funds.
// i.withdraw('100000000000000000') // this rollsback as can't withdraw this much.

// i.withdraw('100000000000000000') // this works and uses default account[0] for msg.sender

// Events - Notice the logs :[..] in the output on the cmd, this is the event MoneySent
// see event data with sender address and amount logged
// i.withdraw('100000000000000000', {from:accounts[1]}).then(function(ret){console.log(ret.logs[0].args);})

// web3.eth.getBalance(accounts[0]); // see balance

// i.withdraw('100000000000000000', {from:accounts[1]}) // specify the account in msg.sender

// web3.eth.getBalance(accounts[1]); // see balance

// i.balances(accounts[0]) query contract storage and get back a big number

// i.balances(accounts[0]).toString() // give you a promise

// const b = await i.balances(accounts[0]) and then b.toString()

// check the contract address balance
//web3.eth.getBalance(i.address)

// send to the contract address directly - this goes to the recieve() if it is defined.
// Note the MoneyReceived event is fired
// i.send("1000000000000000000")
// i.sendTransaction("1000000000000000000") - same


// TODO
// try fallback function
// i.sendTransaction({from: accounts[1], value: web3.utils.toWei("1", 'ether')})
// web3.eth.sendTransaction({from: accounts[0], to:i.address, value:web3.utils.toWei("1", 'ether'), data:'0x06540f7e'}).then(console.log);

