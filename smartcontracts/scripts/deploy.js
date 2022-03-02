const { ethers } = require('hardhat');

async function main() {
  const NFTMarketplaceContract = await ethers.getContractFactory(
    'NFTMarketplace'
  );

  const deployedContract = await NFTMarketplaceContract.deploy();
  await deployedContract.wait();

  console.log(
    'NFT Marketplace Contract deployed on address: ',
    deployedContract.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
