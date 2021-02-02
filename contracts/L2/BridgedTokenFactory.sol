//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "../L1/IVault.sol";
import "./BridgedERC777Token.sol";
import "./IBridgedTokenFactory.sol";


interface ArbSys {
  function sendTxToL1(address destAddr, bytes calldata calldataForL1) external payable;
}

contract BridgedTokenFactory is IBridgedTokenFactory {
  using Address for address;

  bytes32 public constant TOKEN_BYTECODE_HASH = keccak256(type(BridgedERC777Token).creationCode);

  bytes32 public withdrawalHead;

  address private _nextToken;

  event TokenCreated(address l1Token, address l2Token, bytes32 withdrawalHash);
  event Withdrawal(bytes32 indexed claimId, address indexed token, address indexed destination, uint256 amount);

  function calculateTokenAddress(address l1Token) public view returns (address calculatedAddress) {
    calculatedAddress = address(uint(keccak256(abi.encodePacked(
      byte(0xff),
      address(this),
      bytes32(l1Token),
      TOKEN_BYTECODE_HASH
    ))));
  }

  function createToken(address l1Token) public {
    _nextToken = l1Token;
    address l2Token = address(new BridgedERC777Token{salt: bytes32(l1Token)}());
    _nextToken = address(0);

    emit TokenCreated(l1Token, l2Token);
  }

  function getTokenAddress(address l1Token) public returns (address tokenAddress) {
    tokenAddress = calculateTokenAddress(l1Token);

    if(!tokenAddress.isContract()) {
      createToken(l1Token);
      assert(tokenAddress.isContract());
    }
  }

  function deposit(address l1Token, address destination, uint256 amount) external override {
    require(msg.sender == address(this));
    address l2Token = getTokenAddress(l1Token);
    BridgedERC777Token(l2Token).mint(destination, amount);
  }

  function withdraw(address l1Token, uint256 amount, address destination) external override returns (bytes32 claimId) {
    require(msg.sender == calculateTokenAddress(l1Token));

    bytes32 withdrawalHash = keccak256(abi.encodePacked(l1Token, amount, destination));
    claimId = keccak256(abi.encodePacked(withdrawalHead, withdrawalHash));

    ArbSys(100).sendTxToL1(
      address(this),
      abi.encodeWithSignature(
        IVault.withdrawFromL2.selector,
        claimId,
        l1Token,
        amount,
        destination
      )
    );
    emit Withdrawal(claimId, l1Token, destination, amount, withdrawalHash);
  }

  function verifyWithdrawal(
    bytes32 previousHead,
    address l1Token,
    uint256 amount,
    address destination
  ) external view returns (bool) {
    bytes32 withdrawalHash = keccak256(abi.encodePacked(l1Token, amount, destination));
    bytes32 claimId = keccak256(abi.encodePacked(previousHead, withdrawalHash));
    return claimId == withdrawalHead;
  }

  function updateTokenInfo(
    address l1Token,
    string calldata name,
    string calldata symbol,
    uint256 granularity
  ) external override {
    require(msg.sender == address(this));
    BridgedERC777Token(getTokenAddress(l1Token)).updateTokenInfo(name, symbol, granularity);
  }

  function getNextToken() external override view returns (address) {
    return _nextToken;
  }
}

