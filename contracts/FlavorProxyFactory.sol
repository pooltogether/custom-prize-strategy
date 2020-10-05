// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.7.0;

import "./FlavorStrategy.sol";
import "@pooltogether/pooltogether-contracts/contracts/external/openzeppelin/ProxyFactory.sol";

/// @title Creates a minimal proxy to the FlavorStrategy prize strategy.  Very cheap to deploy.
contract FlavorProxyFactory is ProxyFactory {

  FlavorStrategy public instance;

  constructor () public {
    instance = new FlavorStrategy();
  }

  function create() external returns (FlavorStrategy) {
    return FlavorStrategy(deployMinimal(address(instance), ""));
  }

}
