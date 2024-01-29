// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const deploy = hre.ethers.getContractFactory("FactoryMulisigWallet");
  const contract = await deploy.deploy();
  await contract.deployed();
  console.log("FactoryMulisigWallet deployed to:", contract.address);
  console.log(
    "FactoryMulisigWallet deployed to:",
    contract.deployTransaction.hash
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
