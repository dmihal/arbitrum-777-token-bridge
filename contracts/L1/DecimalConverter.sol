//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library DecimalConverter {
  function from777to20(uint256 decimals, uint amount) internal view returns (uint256) {
    require(decimals <= 18, 'DEC');
    return amount / (10 ** (18 - decimals));
  }

  function from20to777(uint256 decimals, uint amount) internal view returns (uint256) {
    require(decimals <= 18, 'DEC');
    return amount * (10 ** (18 - decimals));
  }
}
