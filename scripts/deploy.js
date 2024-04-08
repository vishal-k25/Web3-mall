// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { ethers } = require("hardhat");
const { items } = require("../src/items.json");
const fs = require("fs");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

async function main() {
  // Setup accounts
  const [deployer] = await ethers.getSigners();

  // Deploy web3mall
  const Web3mall = await hre.ethers.getContractFactory("Web3mall");
  const web3mall = await Web3mall.deploy();
  await web3mall.deployed();

  // Listing items...
  for (let i = 0; i < items.length; i++) {
    const transaction = await web3mall
      .connect(deployer)
      .list(
        items[i].id,
        items[i].name,
        items[i].category,
        items[i].image,
        tokens(items[i].price),
        items[i].rating,
        items[i].stock
      );

    await transaction.wait();

    console.log(`Listed item ${items[i].id}: ${items[i].name}`);

  }

  const address = JSON.stringify({ address: web3mall.address }, null, 4)
  fs.writeFile('./src/abis/web3mall.json', address, 'utf8', (err) => {
    if (err) {
      console.error(err)
      return
    }
    console.log('Deployed contract address', web3mall.address)
  })
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
