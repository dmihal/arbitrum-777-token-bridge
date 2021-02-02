//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IBridgedTokenFactory {
  function deposit(address l1Token, address destination, uint256 amount) external;

  function updateTokenInfo(
    address l1Token,
    string calldata name,
    string calldata symbol,
    uint256 granularity
  ) external;

  function withdraw(address l1Token, uint256 amount) external view returns (bytes32);

  function getNextToken() external view returns (address);
}
