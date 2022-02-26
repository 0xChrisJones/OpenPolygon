//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

import "../node_modules/hardhat/console.sol";

contract NFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokensIdCounter;
  address nftMarketplaceContractAddress;

  event NFTCreated(uint id, string uri, address mintedTo);

  constructor(address contractAddress) ERC721("OpenPolygon Tokens", "OPT") {
    nftMarketplaceContractAddress = contractAddress;
  }

  function createNFT(string memory tokenURI) public returns (uint) {
    _tokensIdCounter.increment();
    uint256 tokenID = _tokensIdCounter.current();

    _mint(msg.sender, tokenID);
    _setTokenURI(tokenID, tokenURI);
    setApprovalForAll(nftMarketplaceContractAddress, true);

    emit NFTCreated(tokenID, tokenURI, msg.sender);

    return tokenID;
  }
}
