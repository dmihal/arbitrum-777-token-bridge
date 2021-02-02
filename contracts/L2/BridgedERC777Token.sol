//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./OZERC777.sol";
import "./IBridgedTokenFactory.sol";

contract BridgedERC777Token is OZERC777 {
  address public immutable l1Token;
  address public immutable factory;

  constructor() {
    factory = msg.sender;
    l1Token = IBridgedTokenFactory(msg.sender).getNextToken();
  }

  modifier onlyFactory {
    require(msg.sender == factory);
    _;
  }

  function mint(address recipient, uint256 amount) external onlyFactory {
    _mint(recipient, amount);
  }

  function withdraw(address recipient, uint256 amount) external returns (bytes32) {
    _burn(msg.sender, amount);
    return IBridgedTokenFactory(factory).withdraw(l1Token, amount);
  }

  function updateTokenInfo(
    string calldata name,
    string calldata symbol,
    uint256 granularity
  ) external onlyFactory {
    _name = name;
    _symbol = symbol;
    _granularity = granularity;
  }
}
