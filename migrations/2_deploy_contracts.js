var CDR = artifacts.require("./CDR.sol")

module.exports = function(deployer) {
  const tokenAmount = web3.toWei(18000000, "ether");
  deployer.deploy(CDR, tokenAmount);
};
