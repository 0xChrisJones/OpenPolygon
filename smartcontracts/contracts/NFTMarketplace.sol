//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "../node_modules/hardhat/console.sol";

contract NFTMarketplace is ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  uint256 listingFee = 0.025 ether;
  address payable owner;

  mapping(uint256 => MarketItem) private idToMarketItem;
  
  struct MarketItem {
    uint256 tokenID;
    address payable seller;
    address payable owner;
    uint256 price;
    bool sold;
  }

  event MarketItemCreated (
    uint256 indexed tokenId,
    address seller,
    uint256 price
  );

  constructor() {  
    owner = payable(msg.sender);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can access this functionality");
    _;
  }

  function updateListingFee(uint256 _listingFee) public onlyOwner {
    listingFee = _listingFee;
  }
  function getListingFee() public view returns (uint256) {
    return listingFee;
  }
}
