//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "../node_modules/hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage, ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Counters.Counter private _tokensSold;

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

  constructor() ERC721("OpenPolygon Tokens", "OPT") {  
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

  function createAndListItem(string memory tokenURI, uint256 price) public payable nonReentrant returns (uint256) {
    _tokenIds.increment();
    uint256 newTokenID = _tokenIds.current();

    _mint(msg.sender, newTokenID);
    _setTokenURI(newTokenID, tokenURI);
    listItem(newTokenID, price);
    return newTokenID;
  }

  function listItem(uint256 itemID, uint256 price) private {
    require(price > 0.1 ether, "Price must be at least 0.1 MATIC");
    require(msg.value >= listingFee, "Listing fee not sufficient");

    idToMarketItem[itemID] = MarketItem(
      itemID,
      payable(msg.sender),
      payable(address(this)),
      price,
      false
    );

    _transfer(msg.sender, address(this), itemID);
    emit MarketItemCreated(
      itemID,
      msg.sender,
      price
    );
  }
}
