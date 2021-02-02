//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

interface IVault {
  function withdrawFromL2(
    bytes32 claim,
    address token,
    address owner,
    uint256 amount
  ) external;
}
