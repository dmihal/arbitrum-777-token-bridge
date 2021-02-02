//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "./ILiquidityProvider.sol";
import "./Vault.sol";

contract SimpleLiquidityProvider is ILiquidityProvider {
  Vault public immutable vault;
  address public immutable signer;

  constructor(Vault _vault, address _signer) {
    vault = _vault;
    signer = _signer;
  }

  function receiveTicket(
    address token,
    address owner,
    bytes32 claim,
    uint256 payment,
    uint256 expiration,
    bytes calldata signature,
    uint256 id
  ) external override {
    require(expiration < block.timestamp, "EXPIRED");
    
    bytes32 saleHash = keccak256(abi.encodePacked(token, claim, owner, payment, expiration));
    address signatureSigner = ECDSA.recover(saleHash, signature);
    require(signer == signatureSigner, "BAD_SIG");

    require(id == createId(address(vault), token, owner, claim), "ID");

    if (payment > 0) {
      TransferHelper.transfer(token, owner, payment);
    }
  }

  function withdraw(address token, uint256 amount) external {
    require(msg.sender == signer, "SIGNER");

    TransferHelper.transfer(token, msg.sender, amount);
  }

  function createId(address source, address token, address owner, bytes32 claim) public pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(token, source, owner, claim)));
  }
}
