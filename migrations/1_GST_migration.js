const GST = artifacts.require("GST");
module.exports = function (deployer) {
      deployer.deploy(GST, 100000);
};