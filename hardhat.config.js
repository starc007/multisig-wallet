require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {},
    base_goerli: {
      url: "https://base-goerli.g.alchemy.com/v2/J-YXzcHw9UPglftjZKH6zD92TkJRhdWq",
      accounts: [""],
      gasPrice: 1000000000,
      saveDeployments: true,
    },
  },
};
