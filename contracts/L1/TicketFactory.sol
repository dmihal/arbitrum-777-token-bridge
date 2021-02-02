// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TicketFactory is ERC721 {
  constructor() ERC721("Vault Claim", "VLT") {}

  function createId(address source, address token, address owner, bytes32 claim) public pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(token, source, owner, claim)));
  }

  function mint(address token, address owner, bytes32 claim, address recipient) external returns (uint256 id) {
    id = createId(msg.sender, token, owner, claim);
    _mint(recipient, id);
  }

  function exists(uint256 tokenId) public view returns (bool) {
    return _exists(tokenId);
  }

  function exists(address source, address token, address owner, bytes32 claim) public view returns (bool) {
    return _exists(createId(source, token, owner, claim));
  }

  function burn(address token, address owner, bytes32 claim) external returns (address tokenOwner) {
    uint256 id = createId(msg.sender, token, owner, claim);
    tokenOwner = ownerOf(id);
    _burn(id);
  }
}
