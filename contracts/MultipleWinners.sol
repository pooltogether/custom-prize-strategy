// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@pooltogether/pooltogether-contracts/contracts/prize-strategy/PeriodicPrizeStrategy.sol";
import "@nomiclabs/buidler/console.sol";

contract MultipleWinners is PeriodicPrizeStrategy {

  uint256 public numberOfWinners;

  function initialize(
    address _trustedForwarder,
    uint256 _prizePeriodStart,
    uint256 _prizePeriodSeconds,
    PrizePool _prizePool,
    address _ticket,
    address _sponsorship,
    RNGInterface _rng,
    address[] memory _externalErc20s,
    uint256 _numberOfWinners
  ) public initializer {
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
    require(_numberOfWinners > 0, "MultipleWinners/num-gt-zero");
    numberOfWinners = _numberOfWinners;
  }

  function _distribute(uint256 randomNumber) internal override {
    uint256 prize = prizePool.captureAwardBalance();

    console.log("First winner: ", randomNumber);

    // main winner gets all external tokens
    address mainWinner = ticket.draw(randomNumber);
    _awardAllExternalTokens(mainWinner);

    // yield prize is split up
    // Track nextPrize and prize separately to eliminate dust
    uint256 prizeShare = prize.div(numberOfWinners);

    console.log("prizeShare: ", prizeShare);

    uint256 totalSupply = IERC20(address(ticket)).totalSupply();
    uint256 ticketSplit = totalSupply.div(numberOfWinners);

    console.log("numberOfWinners: ", numberOfWinners);
    console.log("totalSupply: ", totalSupply);
    console.log("ticketSplit: ", ticketSplit);

    uint256 nextRandom = randomNumber.add(ticketSplit);
    // the other winners receive their prizeShares
    for (uint256 winnerCount = 0; winnerCount < numberOfWinners; winnerCount++) {
      console.log("WinnerCount, random number: ", winnerCount, nextRandom);
      address nextWinner = ticket.draw(nextRandom);
      console.log("nextWinner: ", nextWinner);
      nextRandom = nextRandom.add(ticketSplit);
      console.log("nextRandom: ", nextRandom);
      _awardTickets(nextWinner, prizeShare);
    }
  }
}
