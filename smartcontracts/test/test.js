const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('NFTMarketplace', function () {
  it('Should return and update listing fee', async function () {
    const NFTMarketplaceContract = await ethers.getContractFactory(
      'NFTMarketplace'
    );
    const NFTMarketplace = await NFTMarketplaceContract.deploy();
    await NFTMarketplace.deployed();

    const newListingFee = ethers.utils.parseUnits('0.5', 'ether');
    await NFTMarketplace.updateListingFee(newListingFee);

    let listingFee = await NFTMarketplace.getListingFee();
    listingFee = listingFee.toString();
    expect(listingFee).to.equal(newListingFee.toString());
  });
  it('Should create and list marketplace items', async function () {
    const NFTMarketplaceContract = await ethers.getContractFactory(
      'NFTMarketplace'
    );
    const NFTMarketplace = await NFTMarketplaceContract.deploy();
    await NFTMarketplace.deployed();

    let listingFee = await NFTMarketplace.getListingFee();
    listingFee = listingFee.toString();

    const tokenPrice = ethers.utils.parseUnits('1', 'ether');

    await NFTMarketplace.createAndListItem('myTokenLink', tokenPrice, {
      value: listingFee,
    });

    let listedItems = await NFTMarketplace.fetchListedItems();
    expect(listedItems.length).to.equal(1);
  });
  it('Should return marketplace items', async function () {
    const NFTMarketplaceContract = await ethers.getContractFactory(
      'NFTMarketplace'
    );
    const NFTMarketplace = await NFTMarketplaceContract.deploy();
    await NFTMarketplace.deployed();

    let listingFee = await NFTMarketplace.getListingFee();
    listingFee = listingFee.toString();

    const tokenPrice = ethers.utils.parseUnits('1', 'ether');

    await NFTMarketplace.createAndListItem('myTokenLink1', tokenPrice, {
      value: listingFee,
    });
    await NFTMarketplace.createAndListItem('myTokenLink2', tokenPrice, {
      value: listingFee,
    });

    let unsoldItems = await NFTMarketplace.fetchUnsoldItems();
    expect(unsoldItems.length).to.equal(2);
  });
  it('Should delist and burn marketplace items', async function () {
    const NFTMarketplaceContract = await ethers.getContractFactory(
      'NFTMarketplace'
    );
    const NFTMarketplace = await NFTMarketplaceContract.deploy();
    await NFTMarketplace.deployed();

    let listingFee = await NFTMarketplace.getListingFee();
    listingFee = listingFee.toString();

    const tokenPrice = ethers.utils.parseUnits('1', 'ether');

    await NFTMarketplace.createAndListItem('myTokenLink', tokenPrice, {
      value: listingFee,
    });

    let listedItems = await NFTMarketplace.fetchListedItems();
    expect(listedItems.length).to.equal(1);

    await NFTMarketplace.delistItem(1);

    let myItems = await NFTMarketplace.fetchMyItems();
    expect(myItems.length).to.equal(1);

    listedItems = await NFTMarketplace.fetchListedItems();
    expect(listedItems.length).to.equal(0);

    await NFTMarketplace.burnItem(1);

    myItems = await NFTMarketplace.fetchMyItems();
    expect(myItems.length).to.equal(0);
  });

  it('Should execute marketplace sales and resells', async function () {
    const NFTMarketplaceContract = await ethers.getContractFactory(
      'NFTMarketplace'
    );
    const NFTMarketplace = await NFTMarketplaceContract.deploy();
    await NFTMarketplace.deployed();

    let listingFee = await NFTMarketplace.getListingFee();
    listingFee = listingFee.toString();

    const tokenPrice = ethers.utils.parseUnits('1', 'ether');

    const [_, sellerAddress, buyerAddress] = await ethers.getSigners();

    await NFTMarketplace.connect(sellerAddress).createAndListItem(
      'myTokenLink',
      tokenPrice,
      {
        value: listingFee,
      }
    );

    let listedItems = await NFTMarketplace.connect(
      sellerAddress
    ).fetchListedItems();
    expect(listedItems.length).to.equal(1);

    await NFTMarketplace.connect(buyerAddress).createItemSale(1, {
      value: tokenPrice,
    });

    let itemsSold = await NFTMarketplace.getTokensSoldCount();
    expect(itemsSold).to.equal(1);

    let myItems = await NFTMarketplace.connect(buyerAddress).fetchMyItems();
    expect(myItems.length).to.equal(1);

    await NFTMarketplace.connect(buyerAddress).resellItem(1, tokenPrice, {
      value: listingFee,
    });

    listedItems = await NFTMarketplace.connect(buyerAddress).fetchListedItems();
    expect(listedItems.length).to.equal(1);

    myItems = await NFTMarketplace.connect(buyerAddress).fetchMyItems();
    expect(myItems.length).to.equal(0);
  });
});
