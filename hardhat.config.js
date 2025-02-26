/**
 * @type import('hardhat/config').HardhatUserConfig
 */

require("@nomicfoundation/hardhat-chai-matchers");
require("@nomicfoundation/hardhat-network-helpers");
require("@nomicfoundation/hardhat-ethers");
require("@nomiclabs/hardhat-web3");
require("dotenv").config();

module.exports = {
	solidity: {
		version: "0.8.26",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
			viaIR: true,
		},
	},
	defaultNetwork: "hardhat",
	networks: {
		hardhat: {
			allowUnlimitedContractSize: false,
		}
	}
};
