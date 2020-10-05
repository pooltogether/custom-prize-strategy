// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
import "@pooltogether/pooltogether-contracts/contracts/prize-strategy/PeriodicPrizeStrategy.sol";
import "@nomiclabs/buidler/console.sol";
import "./Ownable.sol";

contract FlavorStrategy is PeriodicPrizeStrategy, Ownable {

  // mapping from asset symbol to pod pod address
  mapping(string => address) public podAddresses;
  // mapping storing asset prices at start of prize period
  mapping(string => uint256) public startPrizePeriodPrices;

  string[] assetSymbols;

  function initialize(
    address _trustedForwarder,
    uint256 _prizePeriodStart,
    uint256 _prizePeriodSeconds,
    PrizePool _prizePool,
    address _ticket,
    address _sponsorship,
    RNGInterface _rng,
    address[] memory _externalErc20s,
  ) public initializer {
    // TODO: rng isn't needed for flavor strategy
    PeriodicPrizeStrategy.initialize(
      _trustedForwarder,
      _prizePeriodStart,
      _prizePeriodSeconds,
      _prizePool,
      _ticket,
      _sponsorship,
      _rng,
      _externalErc20s
    );

    startPrizePeriod();

  }

  function addPodAddress(string assetSymbol, address podAddress) public onlyOwner {
    // only owner can add pod addresses
    require(!podAddresses[assetSymbol])
    podAddresses[assetSymbol] = podAddress;
  }

  function startPrizePeriod internal {
    // TODO: get oracle price feed data, or get it passed in by completeAward
      for (uint i=0; i<assetSymbols.length; i++) {
        uint256 assetPrice = i * 100; // placeholder value for testing
        startPrizePeriodPrices[assetSymbols[i]] = assetPrice;
      }
  }

  function calculateWinningAsset internal returns (string) {
    // TODO: for each asset in assetSymbols, get latest price from oracle
    // calculate percentage change compared to startPrizePeriodPrices
    // return assetSymbol with greatest calculated value
  }

/// @notice Completes the award process and awards the winners.
// Because randomNumber isn't used, startAward function is not needed
function completeAward(string winningAsset) external override requireCanCompleteAward {
  // string winningAsset = calculateWinningAsset();
  // for initial testing, assetSymbol is passed in manually

  _distribute(winningAsset);

  // to avoid clock drift, we should calculate the start time based on the previous period start time.
  prizePeriodStartedAt = _calculateNextPrizePeriodStartTime(_currentTime());

  emit PrizePoolAwarded(_msgSender(), winningAsset);
  emit PrizePoolOpened(_msgSender(), prizePeriodStartedAt);
}

  function _distribute(string winningAsset) internal override {
    uint256 prize = prizePool.captureAwardBalance();
    console.log("Winning asset: ", winningAsset);
    address winningPodAddress = podAddresses[winningAsset];
    console.log("Winning pod address: ", winningPodAddress);

    // winner gets all external tokens
    // TODO: is award all external tokens needed?
    _awardAllExternalTokens(winningPodAddress);
    _awardTickets(winningPodAddress, 100);
  }

  modifier requireCanCompleteAward() {
    require(_isPrizePeriodOver(), "PeriodicPrizeStrategy/prize-period-not-over");
    _;
  }
}
