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
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: {
        mnemonic: process.env.HDWALLET_MNEMONIC
      }
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: {
        mnemonic: process.env.HDWALLET_MNEMONIC
      }
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: {
        mnemonic: process.env.HDWALLET_MNEMONIC
      }
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: {
        mnemonic: process.env.HDWALLET_MNEMONIC
      }
    }
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  }
};
