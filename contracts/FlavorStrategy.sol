// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
import "@pooltogether/pooltogether-contracts/contracts/prize-strategy/PeriodicPrizeStrategy.sol";
import "@nomiclabs/buidler/console.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FlavorStrategy is PeriodicPrizeStrategy {

  // mapping from asset symbol to pod address
  mapping(string => address) public podAddresses;
  // mapping storing asset prices at start of prize period
  mapping(string => uint256) public startPrizePeriodPrices;

  string[] assetSymbols;

  AggregatorV3Interface internal priceFeed;

  constructor() public {
    // Kovan price feeds
    ethPriceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331)
    btcPriceFeed = AggregatorV3Interface(0x6135b13325bfC4B00278B4abC5e20bbce2D6580e)
    snxPriceFeed = AggregatorV3Interface(0x31f93DA9823d737b7E44bdee0DF389Fe62Fd1AcD)

    // Mainnet price feeds
    // ethPriceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419)
    // btcPriceFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c)
    // snxPriceFeed = AggregatorV3Interface(0x79291A9d692Df95334B1a0B3B4AE6bC606782f8c)

  }

  function initialize(
    address _trustedForwarder,
    uint256 _prizePeriodStart,
    uint256 _prizePeriodSeconds,
    PrizePool _prizePool,
    address _ticket,
    address _sponsorship,
    RNGInterface _rng,
    address[] memory _externalErc20s
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
    require(!podAddresses[assetSymbol]);
    podAddresses[assetSymbol] = podAddress;
    assetSymbols.push(assetSymbol);
  }

  function getEthPrice() public view returns (int) {
    (
      uint80 roundID, 
      int price,
      uint startedAt,
      uint timeStamp,
      uint80 answeredInRound
    ) = ethPriceFeed.latestRoundData();
    // If the round is not complete yet, timestamp is 0
    require(timeStamp > 0, "Round not complete");
    return price;
  }

  function getBtcPrice() public view returns (int) {
    (
      uint80 roundID, 
      int price,
      uint startedAt,
      uint timeStamp,
      uint80 answeredInRound
    ) = btcPriceFeed.latestRoundData();
    // If the round is not complete yet, timestamp is 0
    require(timeStamp > 0, "Round not complete");
    return price;
  }

  function getAavePrice() public view returns (int) {
    (
      uint80 roundID, 
      int price,
      uint startedAt,
      uint timeStamp,
      uint80 answeredInRound
    ) = aavePriceFeed.latestRoundData();
    // If the round is not complete yet, timestamp is 0
    require(timeStamp > 0, "Round not complete");
    return price;
  }

  struct Asset {
    uint price;
    string name;
  
  }
  function getAssetPrices() internal returns (Asset[]) {
    Asset[] assetPrices

    for (uint i = 0; i < assetSymbols.length, i++) {
      require(assetSymbols[i] == "ETH/USD" || assetSymbols[i] == "BTC/USD" || assetSymbols[i] == "SNX/USD" )

      if (assetSymbols[i] == "ETH/USD") {
        Asset storage a;
        ethPrice = getEthPrice()
        a.price = ethPrice
        a.name = "ETH/USD"
        assetPrices.push(a)
      } else if (assetSymbols[i] == "BTC/USD") {
        Asset storage a;
        btcPrice = getBtcPrice()
        a.price = btcPrice
        a.name = "BTC/USD"
        assetPrices.push(a)
      } else if (assetSymbols[i] == "SNX/USD") {
        Asset storage a;
        snxPrice = getSnxPrice()
        a.price = snxPrice
        a.name = "SNX/USD"
        assetPrices.push(a)
      }
    }
  }

  function startPrizePeriod() internal {
    // TODO: get oracle price feed data, or get it passed in by completeAward
      for (uint i=0; i<assetSymbols.length; i++) {
        uint256 assetPrice = i * 100; // placeholder value for testing
        startPrizePeriodPrices[assetSymbols[i]] = assetPrice;
      }
  }

  function calculateWinningAsset() internal returns (string) {
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
