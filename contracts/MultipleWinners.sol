// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "@pooltogether/pooltogether-contracts/contracts/prize-strategy/PeriodicPrizeStrategy.sol";

contract MultipleWinners is PeriodicPrizeStrategy {

  uint256 numberOfWinners;

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

    // main winner gets all external tokens
    address mainWinner = ticket.draw(randomNumber);
    _awardAllExternalTokens(mainWinner);

    // yield prize is split up
    // Track nextPrize and prize separately to eliminate dust
    uint256 share = prize.div(numberOfWinners);
    uint256 dust = prize.sub(share.mul(numberOfWinners));

    // main winner gets their share plus the dust
    _awardTickets(mainWinner, share.add(dust));

    uint256 split = IERC20(address(ticket)).totalSupply().div(numberOfWinners);
    // the other winners receive their shares
    for (uint256 winnerCount = 1; winnerCount < numberOfWinners; winnerCount++) {
      address nextWinner = ticket.draw(randomNumber.add(split.mul(winnerCount)));
      _awardTickets(nextWinner, share);
    }
  }
}
