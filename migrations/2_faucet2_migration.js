// eslint-disable-next-line no-undef
const FaucetContract2 = artifacts.require("Faucet2");

module.exports = function (deployer, network, accounts) {
   deployer.deploy(FaucetContract2, { from: accounts[0] }); // default account but can me changed here.
};
