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

  mapping(uint256 => MarketItem) private idToToken;
  
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

  event MarketItemSale (
    uint256 tokenId,
    address owner
  );

  constructor() ERC721("OpenPolygon Tokens", "OPT") {  
    owner = payable(msg.sender);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can access this functionality");
    _;
  }

  function getTokensSoldCount() public view returns (uint256) {
    return _tokensSold.current();
  }

  function updateListingFee(uint256 _listingFee) public onlyOwner {
    listingFee = _listingFee;
  }

  function getListingFee() public view returns (uint256) {
    return listingFee;
  }

  function createAndListItem(string memory tokenURI, uint256 price) public payable nonReentrant returns (uint256) {
    require(price > 0.1 ether, "Price must be at least 0.1 MATIC");
    require(msg.value >= listingFee, "Listing fee not sufficient");

    _tokenIds.increment();
    uint256 newTokenID = _tokenIds.current();

    _mint(msg.sender, newTokenID);
    _setTokenURI(newTokenID, tokenURI);

    idToToken[newTokenID] = MarketItem(
      newTokenID,
      payable(msg.sender),
      payable(address(this)),
      price,
      false
    );
    _transfer(msg.sender, address(this), newTokenID);

    emit MarketItemCreated(
      newTokenID,
      msg.sender,
      price
    );
    return newTokenID;
  }

  function createItemSale(uint256 tokenID) public payable nonReentrant {
    uint256 price = idToToken[tokenID].price;
    require(price == msg.value, "Funds provided do not cover the token price");
    idToToken[tokenID].owner = payable(msg.sender);
    idToToken[tokenID].sold = true;
    idToToken[tokenID].seller = payable(address(0));
    _tokensSold.increment();
    _transfer(address(this), msg.sender, tokenID);
    payable(idToToken[tokenID].seller).transfer(msg.value);

    emit MarketItemSale(
      tokenID,
      msg.sender
    );
  }

  function resellItem(uint256 tokenID, uint256 price) public payable nonReentrant {
    require(idToToken[tokenID].owner == msg.sender, "Only owner of the item can resell it.");
    require(msg.value >= listingFee, "Listing fee not sufficient");

    _transfer(msg.sender, address(this), tokenID);

    idToToken[tokenID].sold = false;
    idToToken[tokenID].price = price;
    idToToken[tokenID].seller = payable(msg.sender);
    idToToken[tokenID].owner = payable(address(this));
    _tokensSold.decrement();
  }

  function delistItem(uint256 tokenID) public {
    require(idToToken[tokenID].owner == msg.sender, "Only owner of the item can resell it.");
    require(idToToken[tokenID].sold == false, "Only listed items can be unlisted.");

    _transfer(address(this), msg.sender, tokenID);

    idToToken[tokenID].sold = true;
    idToToken[tokenID].seller = payable(address(0));
    idToToken[tokenID].owner = payable(msg.sender);
    _tokensSold.decrement();
  }

  function fetchUnsoldItems() public view returns (MarketItem[] memory) {
    uint256 itemsCount = _tokenIds.current();
    uint256 itemsSold = _tokensSold.current();
    uint256 unsoldItemCount = itemsCount - itemsSold;

    MarketItem[] memory unsoldItems = new MarketItem[](unsoldItemCount);

    for (uint256 i = 0; i < itemsCount; i++) {
      if(idToToken[i+1].owner == payable(address(this))) {
        MarketItem memory currentItem = idToToken[i + 1];
        unsoldItems[i] = currentItem;
      }
    }
    return unsoldItems;
  }

  function fetchMyItems() public view returns (MarketItem[] memory) {
    uint256 itemsCount = _tokenIds.current();
    uint256 ownedItemsCount = 0;

    for (uint256 i = 0; i < itemsCount; i++) {
      if(msg.sender == idToToken[i + 1].owner) 
      ownedItemsCount += 1;
    }

    MarketItem[] memory ownedItems = new MarketItem[](ownedItemsCount);

    for (uint256 i = 0; i < itemsCount; i++) {
      uint256 currentID = i + 1; 

      if(msg.sender == idToToken[currentID].owner) 
      {
        MarketItem memory currentItem = idToToken[currentID];
        ownedItems[i] = currentItem;
      }
    }
    return ownedItems;
  }

  function fetchListedItems() public view returns (MarketItem[] memory) {
    uint256 itemsCount = _tokenIds.current();
    uint256 listedItemsCount = 0;

    for (uint256 i = 0; i < itemsCount; i++)
      if (idToToken[i + 1].seller == payable(msg.sender)) 
        listedItemsCount += 1;
    
    MarketItem[] memory listedItems = new MarketItem[](listedItemsCount);

    for (uint256 i = 0; i < itemsCount; i++) {
      uint256 currentID = i + 1; 
      if (idToToken[currentID].seller == payable(msg.sender)) {
        MarketItem memory currentItem = idToToken[currentID];
        listedItems[i] = currentItem;
      }
    }
    return listedItems;
  }
}
