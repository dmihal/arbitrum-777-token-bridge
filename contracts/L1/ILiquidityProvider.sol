//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface ILiquidityProvider {
  function receiveTicket(
    address token,
    address owner,
    bytes32 claim,
    uint256 payment,
    uint256 expiration,
    bytes calldata signature,
    uint256 id
  ) external;
}
