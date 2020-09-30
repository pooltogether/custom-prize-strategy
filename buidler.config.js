usePlugin("@nomiclabs/buidler-ethers");
usePlugin("@nomiclabs/buidler-waffle");
usePlugin("buidler-deploy");
usePlugin("@nomiclabs/buidler-etherscan");

module.exports = {
  solc: {
    version: "0.6.12",
    optimizer: {
      enabled: true,
      runs: 200
    },
    evmVersion: "istanbul"
  },
  networks: {
    buidlerevm: {
    },
    pt: {
      url: 'http://127.0.0.1:8545'
    }
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  }
};
