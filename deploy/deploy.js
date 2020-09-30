const debug = require('debug')('custom-prize-strategy:deploy')

module.exports = async (buidler) => {
  const { getNamedAccounts, deployments } = buidler
  const { deploy } = deployments
  const { deployer } = await getNamedAccounts()

  debug("\n  Deploying MultipleWinnersProxyFactory...")
  const multipleWinnersProxyFactoryResult = await deploy("MultipleWinnersProxyFactory", {
    from: deployer,
    skipIfAlreadyDeployed: true
  })

  debug("\n Deploying MultipleWinnerBuilder...")
  const multipleWinnersBuilderResult = await deploy("MultipleWinnersBuilder", {
    args: [
      multipleWinnersProxyFactoryResult.address
    ],
    from: deployer,
    skipIfAlreadyDeployed: true
  })

};
