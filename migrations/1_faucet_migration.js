// eslint-disable-next-line no-undef
const FaucetContract = artifacts.require("Faucet");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(FaucetContract, { from: accounts[0] }); // default account but can me changed here.
};
